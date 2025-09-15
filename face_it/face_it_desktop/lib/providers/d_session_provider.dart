import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:content_store/content_store.dart';
import 'package:face_it_desktop/providers/a_files.dart';
import 'package:face_it_desktop/providers/e_preferred_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/cl_socket.dart';
import 'd_online_server.dart';
import 'messages.dart';

final sessionProvider = AsyncNotifierProvider<SessionNotifier, CLSocket?>(
  SessionNotifier.new,
);

class SessionNotifier extends AsyncNotifier<CLSocket?> with CLLogger {
  @override
  String get logPrefix => 'SessionNotifier';

  @override
  FutureOr<CLSocket?> build() async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final tempDirectory = p.join(directories.temp.pathString, 'Sessions');

    final server = await ref.watch(activeAIServerProvider.future);
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
        logAndMsg('Connected: session id ${socket.id}');
        state = AsyncValue.data(
          CLSocket(
            socket: socket,
            server: server,
            tempDirectory: tempDirectory,
          ),
        );
      })
      ..onConnectError((err) {
        logAndMsg('Error: session Connection Failed\n\t$err');

        state = AsyncValue.data(
          CLSocket(
            socket: socket,
            server: server,
            tempDirectory: tempDirectory,
          ),
        );
      })
      ..on('message', onReceiveMessage)
      //..on('result', onReceiveMessage)
      ..on('progress', onReceiveMessage)
      ..onDisconnect((_) {
        logAndMsg('Disconnected');
        state = AsyncValue.data(
          CLSocket(
            socket: socket,
            server: server,
            tempDirectory: tempDirectory,
          ),
        );
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
    return CLSocket(
      socket: socket,
      server: server,
      tempDirectory: tempDirectory,
    );
  }

  void onReceiveMessage(dynamic data) {
    logAndMsg('Received: $data ');
  }

  void sendMsg(String type, dynamic map) {
    logAndMsg('Sending: $type - $map');
    state.value!.socket.emit(type, map);
  }

  void logAndMsg(String msg) {
    log(msg);
    ref.read(messagesProvider.notifier).addMessage(msg);
  }
}
