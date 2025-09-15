import 'package:cl_servers/cl_servers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

@immutable
class CLSocket {
  const CLSocket({
    required this.socket,
    required this.server,
    this.connected = false,
  });
  final io.Socket socket;
  final bool connected;
  final CLServer server;

  bool get isConnected => socket.connected;

  CLSocket copyWith({io.Socket? socket, CLServer? server, bool? connected}) {
    return CLSocket(
      socket: socket ?? this.socket,
      server: server ?? this.server,
      connected: connected ?? this.connected,
    );
  }

  void dispose() {
    socket
      ..disconnect()
      ..dispose();
  }

  @override
  bool operator ==(covariant CLSocket other) {
    if (identical(this, other)) return true;

    return other.socket == socket &&
        other.server == server &&
        other.connected == connected;
  }

  @override
  int get hashCode => socket.hashCode ^ server.hashCode ^ connected.hashCode;

  @override
  String toString() =>
      'ServerIO(socket: $socket, server: $server, connected: $connected)';
}

/*
  ServerIO addMessage(String msg) {
    return copyWith(messages: [...messages, msg]);
  }

  bool sendMessage(msg) {
    if (isConnected) {
      socket.emit("message", msg);
    }

    return isConnected;
  }
 */
