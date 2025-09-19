import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/cl_socket.dart';
import 'active_ai_server.dart';
import 'server_preference.dart';

final socketConnectionProvider =
    AsyncNotifierProvider<SocketConnectionNotifier, CLSocket>(
      SocketConnectionNotifier.new,
    );

class SocketConnectionNotifier extends AsyncNotifier<CLSocket> with CLLogger {
  io.Socket? socket;
  @override
  FutureOr<CLSocket> build() async {
    log('dispose old socket');
    socket
      ?..off('disconnect', onDisconnect)
      ..disconnect()
      ..close()
      ..dispose();
    socket = null;
    final server = await ref.watch(activeAIServerProvider.future);
    if (server == null) {
      log('server not found, socket not created');
      throw Exception('server not available');
    }
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
    final pref = ref.watch(serverPreferenceProvider);
    if (pref.autoConnect) {
      socket?.connect();
    }

    return CLSocket(socket: socket!);
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

  Future<Map<String, dynamic>> aitask(String identifier, String task) async {
    final socket = state.value!.socket;
    final completer = Completer<Map<String, dynamic>>();

    void callback(dynamic data) {
      final map = data as Map<String, dynamic>;
      if (map.keys.contains('identifier') && map['identifier'] == identifier) {
        completer.complete(map);
      }
    }

    socket.on('result', callback);
    state.value!.socket.emit(task, identifier);

    final result = await completer.future;
    socket.off('result', callback);

    return result;
  }

  @override
  String get logPrefix => 'SessionNotifier';

  /*  @override
  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    ref.read(socketMessagesProvider.notifier).addMessage(message);
  } */
}
