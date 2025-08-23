import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/server_io.dart';

final serverIOProvider = AsyncNotifierProvider<ServerIONotifier, ServerIO>(
  ServerIONotifier.new,
);

class ServerIONotifier extends AsyncNotifier<ServerIO> {
  @override
  Future<ServerIO> build() async {
    return ServerIO();
  }

  void connect() {
    state = AsyncData(state.value!.dispose());
    final socket = io.io(
      "http://192.168.0.179:5002",
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // connect manually
          .disableReconnection() // stop infinite retries
          .build(),
    );

    socket.connect();
    state = AsyncData(state.value!.copyWith(socket: () => socket));

    socket.onConnect((_) {
      state = AsyncData(state.value!.copyWith(connected: true));
      addMessage("Connected to server".info);
    });
    socket.onConnectError((err) {
      addMessage('Connection error: $err'.error);
    });
    /*
    _socket!.onError((err) {
      addMessage(' error: $err'.error);
      // Show "Server not available"
    });
    */

    socket.on("message", (data) {
      final msg = data["msg"];
      addMessage("$msg".info);

      if (msg == "done") {
        addMessage("Process finished!".info);
      }
    });

    socket.onDisconnect((_) {
      state = AsyncData(state.value!.dispose());
      addMessage("Disconnected".info);
      addMessage("@Divider");
    });
  }

  void disconnectFromServer() {
    state.value!.socket?.disconnect();
    state = AsyncData(state.value!.dispose());
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
