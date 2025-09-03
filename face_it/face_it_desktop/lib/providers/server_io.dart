import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/server_io.dart';
import 'online_server.dart';

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
    socket.onConnect((_) {
      state = AsyncValue.data(CLSocket(socket: socket));
    });
    socket.onConnectError((err) {
      state = AsyncValue.data(CLSocket(socket: socket));
    });
    socket.on("message", onReceiveMessage);

    socket.onDisconnect((_) {
      state = AsyncValue.data(CLSocket(socket: socket));
    });
    ref.onDispose(() {
      socket.disconnect();
      socket.dispose();
    });
    socket.connect();
    return CLSocket(socket: socket);
  }

  void onReceiveMessage(dynamic data) {
    // ignore: unused_local_variable
    final msg = data["msg"];
  }
}

/* 

final serviceProvider = StateProvider<String?>((ref) {
  return null;
});
final serverIOProvider = AsyncNotifierProvider<ServerIONotifier, ServerIO?>(
  ServerIONotifier.new,
);

class ServerIONotifier extends AsyncNotifier<ServerIO?> {
  @override
  Future<ServerIO?> build() async {
    final registerredURLsAsync = ref.watch(registeredURLsProvider);
    
    final serverId = ref.watch(serviceProvider);
    final servers = ref.watch(provider)
    if (serverId == null) return null;
    final server = 

    
  }

  void sendProcess() {
    if (state.value!.sendMessage("process")) {
      addMessage("Sent 'process' to server".info);
    }
  }

  String logWithTime(String message) {
    final now = DateTime.now().toIso8601String();
    return "[$now] $message";
  }

  void addMessage(String msg) {
    state = AsyncData(state.value!.addMessage(msg));
  }
}

extension Timestamp on String {
  String get warning {
    return "WARNING - $this".withTimestamp;
  }

  String get info {
    return "INFO    - $this".withTimestamp;
  }

  String get error {
    return "ERROR   - $this".withTimestamp;
  }

  String get withTimestamp {
    final now = DateTime.now();
    final formatted = DateFormat("yyyy-MMM-dd HH:mm:ss.SSS").format(now);
    return "[$formatted] : $this";
  }
}
 */
