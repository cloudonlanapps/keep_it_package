import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_services/cl_server_services.dart';
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

final faceRecgProvider =
    StateNotifierProvider<FaceRecgNotifier, ImageFaceMapperList>((ref) {
      return FaceRecgNotifier(ref);
    });

class FaceRecgNotifier extends StateNotifier<ImageFaceMapperList>
    with CLLogger {
  FaceRecgNotifier(this.ref) : super(const ImageFaceMapperList([]));
  final Ref ref;

  void _updateState(ImageFaceMapperList newState) {
    state = newState;
    if (state.ready.isNotEmpty) {
      for (final item in state.ready) {
        recognize(item.image);
      }
    }
  }

  void addImage(String image, {String? serverId}) {
    _updateState(state.insertImage(image, serverId: serverId));
  }

  void removeImage(String image) {
    _updateState(state.removeImage(image));
  }

  void setSessionId(String image, String serverId) {
    _updateState(state.setSessionId(image, serverId));
  }

  void clearSessionId(String image) {
    _updateState(state.clearSessionId(image));
  }

  void setError(String image, String error) {
    _updateState(state.setError(image, error));
  }

  void setIsProcessing(String image) {
    _updateState(state.setIsProcessing(image));
  }

  void setFaces(String image, List<String> faceIds) {
    _updateState(state.setFaces(image, faceIds));
  }

  void reset(String image) {
    _updateState(state.reset(image));
  }

  void resetAll() {
    _updateState(state.resetAll());
  }

  void clearAllSessionId() {
    _updateState(state.clearAllSessionId());
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
      ActivityStatus.ready => mapper,
      ActivityStatus.pending => null, // check if we need to change priority
      ActivityStatus.processingNow => null,
      ActivityStatus.success => retry ? mapper : null, // introduce force
      ActivityStatus.error => retry ? mapper : null, // introduce force
    };
    if (candidate == null) {
      return;
    }
    state = state.setIsPushed(mapper.image);
    unawaited(
      ref
          .read(schedulerNotifierProvider.notifier)
          .pushTask(
            FaceRecTask(
              identifier: mapper.sessionIdentity!,
              priority: priority,
              pre: (identifier) async {
                final mapper = state.getMapper(image);
                if (mapper == null) {
                  log('pre failed as mapper not found');
                  return false;
                }
                if (mapper.status != ActivityStatus.pending) {
                  log(
                    'pre failed as mapper is not in pending state. current status: ${mapper.status}',
                  );
                  return false;
                }

                state = state.setIsProcessing(image);
                return true;
              },
              post: (identifier, resultMap) async {
                if (resultMap.keys.contains('faces')) {
                  log(
                    '$image found ${(resultMap['faces'] as List<dynamic>).length} faces',
                  );
                  await getFaces(image, resultMap['faces'] as List<dynamic>);
                }
                if (resultMap.keys.contains('error')) {
                  state = state.setError(image, resultMap['error'].toString());
                } else {}
                return false;
              },
            ),
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
    log('$image: Detected faces ${faces.map((e) => e.descriptor.identity)}');
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
    log('$identity - FACE RECG RESULT: status: ${updatedFace.status}');
    log(
      '$identity - FACE RECG RESULT: person: ${updatedFace.guesses?.firstOrNull?.person.name}',
    );
    return updatedFace;
  }

  @override
  String get logPrefix => 'FaceRecgNotifier';
}
