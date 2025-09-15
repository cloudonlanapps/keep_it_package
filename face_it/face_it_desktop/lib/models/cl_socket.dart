import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:socket_io_client/socket_io_client.dart' as io;

@immutable
class CLSocket {
  const CLSocket({
    required this.socket,
    required this.server,
    required this.tempDirectory,
    this.connected = false,
  });
  final io.Socket socket;
  final bool connected;
  final CLServer server;
  final String? tempDirectory;

  bool get isConnected => socket.connected;

  CLSocket copyWith({
    io.Socket? socket,
    CLServer? server,
    String? tempDirectory,
    bool? connected,
  }) {
    return CLSocket(
      socket: socket ?? this.socket,
      server: server ?? this.server,
      tempDirectory: tempDirectory ?? this.tempDirectory,
      connected: connected ?? this.connected,
    );
  }

  void dispose() {}

  @override
  bool operator ==(covariant CLSocket other) {
    if (identical(this, other)) return true;

    return other.socket == socket &&
        other.server == server &&
        other.tempDirectory == tempDirectory &&
        other.connected == connected;
  }

  @override
  int get hashCode =>
      socket.hashCode ^
      server.hashCode ^
      tempDirectory.hashCode ^
      connected.hashCode;

  @override
  String toString() =>
      'ServerIO(socket: $socket, server: $server, sessionDir: $tempDirectory connected: $connected)';

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

  String get sessionDirectory {
    if (socket.id == null) {
      throw Exception("Can't create directory without session");
    }
    final sessionId = socket.id!;
    final directory = Directory(p.join(tempDirectory!, sessionId));
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory.path;
  }

  Future<String?> downloadFaceImage(String identity) async {
    if (socket.id == null) return null;
    final sessionId = socket.id!;
    final faceUrl = '/sessions/$sessionId/face/$identity';

    final face = await server.downloadFile(
      faceUrl,
      p.join(sessionDirectory, identity),
    );
    return face;
  }

  Future<String?> downloadFaceVector(String identity) async {
    if (socket.id == null) return null;
    final sessionId = socket.id!;
    final vectorUrl = '/sessions/$sessionId/vector/$identity';

    final vector = await server.downloadFile(
      vectorUrl,
      p.join(sessionDirectory, identity.replaceAll(RegExp(r'\.png$'), '.npy')),
    );
    return vector;
  }
}

extension DownloadExt on CLServer {
  Future<String?> downloadFile(String url, String targetFile) async {
    final response = await get(url, outputFileName: targetFile);

    return response.when(
      validResponse: (result) async {
        return result as String;
      },
      errorResponse: (e, {st}) async {
        print(e);
        return null;
      },
    );
  }
}
