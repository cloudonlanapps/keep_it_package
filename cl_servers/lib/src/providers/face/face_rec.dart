import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../models/ai_task.dart' show FaceRecTask;
import '../../models/face/detected_face.dart';
import '../../models/face/face_descriptor.dart';
import '../../models/rest_api.dart';
import '../active_ai_server.dart';
import '../socket_connection.dart';

extension FaceRegExt on SocketConnectionNotifier {
  Future<List<DetectedFace>> recognize(
    FaceRecTask task, {
    required String downloadPath,
  }) async {
    final Map<String, dynamic> response;
    log('add task to queue');
    log('$task');
    response = await addTask(task);
    if (response.keys.contains('error')) {
      log("Face Recognizer error: ${response['error']}");
      throw Exception(response['error']);
    }

    log(
      'Face Recognizer returned ${(response['faces'] as List<dynamic>).length} faces',
    );

    final List<DetectedFace> faces;
    if (response['faces'] case final List<dynamic> facesList) {
      faces = <DetectedFace>[];
      for (final map in facesList) {
        final face = await lookupOnStore(
          map as Map<String, dynamic>,
          downloadPath: downloadPath,
        );
        if (face != null) {
          faces.add(face);
        }
      }
    } else {
      faces = [];
    }
    log('detected Faces: ${faces.length}');
    return faces;
  }

  Future<DetectedFace?> lookupOnStore(
    Map<String, dynamic> map, {
    required String downloadPath,
  }) async {
    if (!map.containsKey('image')) {
      throw Exception("$logPrefix: response doesn't contains identity");
    }
    map['identity'] = map['image'];

    final identity = map['image'] as String;

    final server = ref
        .read(activeAIServerProvider)
        .whenOrNull(data: (data) => data);

    if (server == null) {
      throw Exception('$logPrefix:server is not available');
    }
    if (socket == null || !socket!.connected) {
      throw Exception('$logPrefix: socket connection lost!');
    }

    final faceUrl = '/sessions/${socket!.id}/face/$identity';
    final vectorUrl = '/sessions/${socket!.id}/vector/$identity';

    final faceFileName = p.join(downloadPath, identity);
    final vectorFilename = p.join(
      downloadPath,
      identity.replaceAll(RegExp(r'\.png$'), '.npy'),
    );

    final facePath = await server.downloadFile(faceUrl, faceFileName);
    final vectorPath = await server.downloadFile(vectorUrl, vectorFilename);

    if (facePath == null || vectorPath == null) {
      if (facePath == null) {
        log('$identity - failed to download face image');
      }
      if (vectorPath == null) {
        log('$identity - failed to download face vector');
      }
      return null;
    }
    log('$identity - face downloaded from session');
    map['imageCache'] = facePath;
    map['vectorCache'] = vectorPath;
    map['imageId'] = identity;

    final face = DetectedFace.notChecked(
      descriptor: FaceDescriptor.fromMap(map),
    );

    final updatedFace = await face.searchDB(server);
    return updatedFace;
  }
}
