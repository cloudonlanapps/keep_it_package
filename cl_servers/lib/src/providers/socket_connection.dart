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
  int count = 0;
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
    log('${task.identifier}: added into the queue');
    queue.add(task);
    processNext();
    return task.result;
  }

  Future<Map<String, dynamic>> process(
    AITask task, {
    required io.Socket socket,
    required int processId,
  }) async {
    if (task.isStillRequired != null) {
      log(
        'processNext-$processId: ${task.identifier}: check if this task is required',
      );
      final isStillRequired = task.isStillRequired!();
      if (!isStillRequired) {
        log(
          'processNext-$processId: ${task.identifier}: user canceled this task, returning with error',
        );

        return {'error': 'task cancelled'};
      }
    }
    final completer = Completer<Map<String, dynamic>>();

    void callback(dynamic data) {
      final map = data as Map<String, dynamic>;
      if (map.keys.contains('identifier') &&
          map['identifier'] == task.identifier) {
        log('processNext-$processId: ${task.identifier} completed');
        completer.complete(map);
      }
    }

    /// FIXME: [LATER] We may need to add more error checks here?
    /// 1. server generated error
    /// 2. time out
    log(
      'processNext-$processId: ${task.identifier}: request sending to server',
    );
    socket
      ..on('result', callback)
      ..emit(task.taskType.name, task.identifier);
    log(
      'processNext-$processId:  ${task.identifier}: waiting for the response',
    );
    final result = await completer.future;

    socket.off('result', callback);
    log(
      'processNext-$processId: ${task.identifier}: response received $result',
    );
    return result;
  }

  Future<void> processNext({int? myCount}) async {
    final int processId;
    if (myCount == null) {
      processId = count;
      count++;
      if (isProcessing) {
        log('processNext-$processId: unable to start as its already running');
        return;
      }
    } else {
      processId = myCount;
    }

    if (socket == null) {
      isProcessing = false;
      log('processNext-$processId: unable to start as socket == null');
      return;
    }

    if (queue.isEmpty) {
      isProcessing = false;
      log('processNext-$processId: unable to start as queue is empty');
      return;
    }

    // Pick the request with the highest priority (lowest number)
    queue.sort((a, b) => a.compareTo(b));
    final req = queue.removeAt(0);

    isProcessing = true;
    try {
      log('processNext-$processId: process started for ${req.identifier}');
      final result = await process(req, socket: socket!, processId: processId);
      log('processNext-$processId: process completed for ${req.identifier}');
      req.complete(result);
    } catch (e) {
      log(
        'processNext-$processId: process completed with error for ${req.identifier}',
      );
      req.complete({'error': '$e'});
    } finally {
      log('processNext-$processId: sleep 200msec');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      log('processNext-$processId: looking for next item}');
      // continue next within the same context
      await processNext(myCount: processId);
    }
    log('processNext-$processId: returned');
  }
}
