import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

@immutable
class CLSocket {
  const CLSocket({required this.socket, this.connected = false});
  final io.Socket socket;
  final bool connected; //

  bool get isConnected => socket.connected;

  CLSocket copyWith({io.Socket? socket, bool? connected}) {
    return CLSocket(
      socket: socket ?? this.socket,
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

    return other.socket == socket && other.connected == connected;
  }

  @override
  int get hashCode => socket.hashCode ^ connected.hashCode;

  @override
  String toString() => 'ServerIO(socket: $socket, connected: $connected)';
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
