// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

@immutable
class ServerIO {
  const ServerIO({
    this.socket,
    this.connected = false,
    this.messages = const [],
  });
  final io.Socket? socket;
  final bool connected;
  final List<String> messages;

  bool get isConnected => socket != null && connected;

  ServerIO copyWith({
    ValueGetter<io.Socket?>? socket,
    bool? connected,
    List<String>? messages,
  }) {
    return ServerIO(
      socket: socket != null ? socket.call() : this.socket,
      connected: connected ?? this.connected,
      messages: messages ?? this.messages,
    );
  }

  ServerIO dispose() {
    if (socket != null) {
      socket!.dispose();
      return copyWith(socket: () => null, connected: false);
    }
    return this;
  }

  ServerIO addMessage(String msg) {
    return copyWith(messages: [...messages, msg]);
  }

  bool sendMessage(msg) {
    if (isConnected) {
      socket!.emit("message", msg);
    }

    return isConnected;
  }
}
