import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/cl_socket.dart';
import 'active_ai_server.dart';
import 'socket_messages.dart';

final socketConnectionProvider =
    AsyncNotifierProviderFamily<SocketConnectionNotifier, CLSocket?, Uri?>(
      SocketConnectionNotifier.new,
    );

class SocketConnectionNotifier extends FamilyAsyncNotifier<CLSocket?, Uri?>
    with CLLogger {
  @override
  FutureOr<CLSocket?> build(Uri? arg) async {
    final server = await ref.watch(activeAIServerProvider(arg).future);
    if (server == null) return null;

    final uri = server.storeURL.uri;
    final socket = io.io(
      uri.toString(),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // connect manually
          .disableReconnection() // stop infinite retries
          .build(),
    );
    socket
      ..onConnect((_) {
        log('Connected: session id ${socket.id}');
        state = AsyncValue.data(CLSocket(socket: socket));
      })
      ..onConnectError((err) {
        log('Error: session Connection Failed\n\t$err');

        state = AsyncValue.data(CLSocket(socket: socket));
      })
      ..on('message', onReceiveMessage)
      //..on('result', onReceiveMessage)
      ..on('progress', onReceiveMessage)
      ..onDisconnect((_) {
        log('Disconnected');
        state = AsyncValue.data(CLSocket(socket: socket));
        socket
          ..disconnect()
          ..dispose();
      });
    ref.onDispose(() {
      socket
        ..disconnect()
        ..dispose();
    });
    Future.delayed(const Duration(seconds: 1), socket.connect);
    return CLSocket(socket: socket);
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
  String get logPrefix => "SessionNotifier";

  @override
  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    ref.read(socketMessagesProvider.notifier).addMessage(message);
  }
}
