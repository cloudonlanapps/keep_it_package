import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'active_ai_server.dart';

final socketConnectionProvider =
    AsyncNotifierProvider<SocketConnectionNotifier, CLSocket>(
      SocketConnectionNotifier.new,
    );

class SocketConnectionNotifier extends AsyncNotifier<CLSocket> with CLLogger {
  io.Socket? socket;

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
        server.baseURL,
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
}
