import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:content_store/storage_service/providers/directories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/ai_task.dart';
import '../models/detected_face.dart';
import '../models/face_descriptor.dart';
import '../models/image_face_mapper.dart';
import '../models/image_face_mapper_list.dart';
import 'f_faces.dart';
import 'scheduler_notifier.dart';

class FaceRecgNotifier extends StateNotifier<ImageFaceMapperList>
    with CLLogger {
  FaceRecgNotifier(this.ref) : super(const ImageFaceMapperList([]));
  final Ref ref;
  void addImage(String image) {
    state = state.insertImage(image);
  }

  void removeImage(String image) {
    state = state.removeImage(image);
  }

  void setSessionId(String image, String serverId) {
    state = state.setSessionId(image, serverId);
  }

  void setError(String image, String error) {
    state = state.setError(image, error);
  }

  void setIsProcessing(String image) {
    state = state.setIsProcessing(image);
  }

  void setFaces(String image, List<String> faceIds) {
    state = state.setFaces(image, faceIds);
  }

  void reset(String image) {
    state = state.reset(image);
  }

  void resetAll() {
    state = state.resetAll();
  }

  void clearSessionId() {
    state = state.clearSessionId();
  }

  void recognize(
    String image, {
    bool retry = false,
    AITaskPriority priority = AITaskPriority.auto,
  }) {
    final mapper = state.getMapper(image);

    if (mapper == null) {
      throw Exception('image not found');
    }
    final candidate = switch (mapper.status) {
      ActivityStatus.premature => null,
      ActivityStatus.pending => mapper,
      ActivityStatus.processingNow => null,
      ActivityStatus.success => retry ? mapper : null, // introduce force
      ActivityStatus.error => retry ? mapper : null, // introduce force
    };
    if (candidate == null) {
      return;
    }
    if (mapper.status != ActivityStatus.pending) {
      state = state.reset(mapper.image);
    }
    ref
        .read(schedulerNotifierProvider.notifier)
        .pushTask(
          FaceRecTask(
            identifier: image,
            priority: priority,
            pre: (identifier) async {
              final mapper = state.getMapper(identifier);
              if (mapper == null) return false;
              if (mapper.status != ActivityStatus.pending) return false;

              state = state.setIsProcessing(image);
              return true;
            },
            post: (identifier, resultMap) async {
              if (resultMap.keys.contains('faces')) {
                log(
                  '$identifier found ${(resultMap['faces'] as List<dynamic>).length} faces',
                );
                await getFaces(identifier, resultMap['faces'] as List<dynamic>);
              }
              if (resultMap.keys.contains('error')) {
                state = state.setError(
                  identifier,
                  resultMap['error'].toString(),
                );
              } else {}
              return false;
            },
          ),
        );
  }

  Future<void> getFaces(String image, List<dynamic> facesList) async {
    final downloadPath = ref
        .read(deviceDirectoriesProvider)
        .whenOrNull(data: (data) => data.temp.pathString);
    if (downloadPath == null) {
      state = state.setError(image, 'download directory is missing');
      return;
    }

    final faces = <DetectedFace>[];
    if (facesList.isNotEmpty) {
      for (final map in facesList) {
        final face = await lookupOnStore(
          map as Map<String, dynamic>,
          downloadPath: downloadPath,
        );
        if (face != null) {
          faces.add(face);
        }
      }
    }
    ref.read(detectedFacesProvider.notifier).upsertFaces(faces);
    state = state.setFaces(
      image,
      faces.map((e) => e.descriptor.identity).toList(),
    );
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

    final socket = ref
        .read(socketConnectionProvider)
        .whenOrNull(data: (data) => data)
        ?.socket;

    if (server == null) {
      throw Exception('$logPrefix:server is not available');
    }
    if (socket == null || !socket.connected) {
      throw Exception('$logPrefix: socket connection lost!');
    }

    final faceUrl = '/sessions/${socket.id}/face/$identity';
    final vectorUrl = '/sessions/${socket.id}/vector/$identity';

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

  @override
  String get logPrefix => 'FaceRecgNotifier';
}
