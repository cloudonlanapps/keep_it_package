import 'dart:async';

import 'package:face_it_desktop/providers/a_files.dart';
import 'package:face_it_desktop/providers/e_preferred_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/cl_socket.dart';
import 'd_online_server.dart';
import 'messages.dart';

final sessionProvider = AsyncNotifierProvider<SessionNotifier, CLSocket?>(
  SessionNotifier.new,
);

class SessionNotifier extends AsyncNotifier<CLSocket?> {
  @override
  FutureOr<CLSocket?> build() async {
    final server = await ref.watch(onlineServerProvider.future);
    if (server == null) return null;

    final uri = server.storeURL.uri.replace(port: 5002);
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
      ..onDisconnect((_) {
        log('Disconnected');
        state = AsyncValue.data(CLSocket(socket: socket));
        socket
          ..disconnect()
          ..dispose();
        ref.read(sessionFilesProvider.notifier).clear();
        ref.read(preferredServerIdProvider.notifier).state = null;
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
    log('Received: ${(data as Map<String, dynamic>)["msg"]}');
  }

  void sendMsg(String type, dynamic map) {
    log('Sending: $type - $map');
    state.value!.socket.emit(type, map);
  }

  void log(String msg) {
    ref.read(messagesProvider.notifier).addMessage(msg);
  }
}
