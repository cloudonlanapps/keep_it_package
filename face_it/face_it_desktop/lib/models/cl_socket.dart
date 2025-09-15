import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
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

  Future<Map<String, dynamic>> aitask(String identifier, String task) async {
    final completer = Completer<Map<String, dynamic>>();

    void callback(dynamic data) {
      final map = data as Map<String, dynamic>;
      if (map.keys.contains('identifier') && map['identifier'] == identifier) {
        completer.complete(map);
      }
    }

    socket
      ..on('result', callback)
      ..emit(task, identifier);

    final result = await completer.future;
    socket.off('result', callback);

    return result;
  }

  Future<String?> uploadMedia(
    String filePath, {
    void Function(double)? onProgress,
  }) async {
    final sessionId = socket.id;
    if (sessionId == null) return null;
    final task = UploadTask.fromFile(
      file: File(filePath),
      url: '${server.storeURL.uri}/sessions/$sessionId/upload',
      fileField: 'media',
      updates: Updates.progress, // request status and progress updates
    );
    final result = await FileDownloader().upload(task, onProgress: onProgress);
    return result.responseBody;
  }
}
