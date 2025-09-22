import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final socketConnectionProvider =
    AsyncNotifierProvider<SocketConnectionNotifier, CLSocket>(
      SocketConnectionNotifier.new,
    );

class SocketConnectionNotifier extends AsyncNotifier<CLSocket> with CLLogger {
  io.Socket? socket;
  bool isProcessing = false;
  final List<AITask> queue = [];

  @override
  String get logPrefix => 'SessionNotifier';

  @override
  FutureOr<CLSocket> build() async {
    if (socket != null) {
      log('dispose old socket');
      socket
        ?..off('disconnect', onDisconnect)
        ..disconnect()
        ..close()
        ..dispose();
      socket = null;
    }
    final server = await ref.watch(activeAIServerProvider.future);
    if (server == null) {
      log('server not found, socket not created');
      throw Exception('server not available');
    }
    await connect(server);

    return CLSocket(socket: socket!);
  }

  Future<void> connect(CLServer server) async {
    log('Create a socket');
    try {
      socket = io.io(
        '${server.storeURL.uri}',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect() // connect manually
            .disableReconnection() // stop infinite retries
            .build(),
      );
    } catch (e) {
      log('Failed to connect to server: $e');
      throw Exception('Failed to connect to server: $e');
    }
    if (socket == null) {
      throw Exception('Failed to connect to server: Unknown Error');
    }

    registerCallbacks(socket!);
  }

  void registerCallbacks(io.Socket soc) {
    soc
      ..onConnect((_) {
        log('Connected: session id ${soc.id}');
        state = AsyncValue.data(CLSocket(socket: soc));
      })
      ..onConnectError((err) {
        log('Error: session Connection Failed\n\t$err');
        state = AsyncValue.data(CLSocket(socket: soc));
      })
      ..on('message', onReceiveMessage)
      ..on('progress', onReceiveMessage)
      ..on('disconnect', onDisconnect);
  }

  void onDisconnect(_) {
    log('onDisconnect: update state');
    ref.invalidateSelf();
  }

  void onReceiveMessage(dynamic data) {
    log('Received: $data ');
  }

  void sendMsg(String type, dynamic map) {
    log('Sending: $type - $map');
    state.value!.socket.emit(type, map);
  }

  Future<Map<String, dynamic>> addTask(AITask task) {
    queue.add(task);
    processNext();
    return task.result;
  }

  Future<Map<String, dynamic>> process(
    AITask task, {
    required io.Socket socket,
  }) async {
    final completer = Completer<Map<String, dynamic>>();

    void callback(dynamic data) {
      final map = data as Map<String, dynamic>;
      if (map.keys.contains('identifier') &&
          map['identifier'] == task.identifier) {
        completer.complete(map);
      }
    }

    socket
      ..on('result', callback)
      ..emit(task.taskType.name, task.identifier);

    final result = await completer.future;
    socket.off('result', callback);

    return result;
  }

  Future<void> processNext() async {
    if (socket == null) return;
    if (isProcessing) return;
    if (queue.isEmpty) return;

    // Pick the request with the highest priority (lowest number)
    queue.sort((a, b) => a.compareTo(b));
    final req = queue.removeAt(0);

    isProcessing = true;
    try {
      final result = await process(req, socket: socket!);
      req.complete(result);
    } catch (e) {
      req.complete({'error': '$e'});
    } finally {
      isProcessing = false;
      await processNext();
    }
  }
}
