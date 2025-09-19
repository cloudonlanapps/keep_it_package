import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

@immutable
class CLSocket {
  const CLSocket({required this.socket});
  final io.Socket socket;

  bool get isConnected => socket.connected;

  CLSocket copyWith({io.Socket? socket, bool? connected}) {
    return CLSocket(socket: socket ?? this.socket);
  }

  void dispose() {
    socket
      ..disconnect()
      ..dispose();
  }

  @override
  bool operator ==(covariant CLSocket other) {
    if (identical(this, other)) return true;

    return other.socket == socket;
  }

  @override
  int get hashCode => socket.hashCode;

  @override
  String toString() => 'ServerIO(socket: $socket)';
}
