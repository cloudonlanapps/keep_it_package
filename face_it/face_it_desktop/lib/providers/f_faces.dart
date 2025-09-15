import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:content_store/content_store.dart';
import 'package:face_it_desktop/models/cl_socket.dart';
import 'package:face_it_desktop/models/face/registered_face.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face/detected_face.dart';
import '../models/face/registered_person.dart';

final detectedFacesProvider =
    AsyncNotifierProvider<DetectedFacesNotifier, Map<String, DetectedFace>>(
      DetectedFacesNotifier.new,
    );

class DetectedFacesNotifier extends AsyncNotifier<Map<String, DetectedFace>> {
  late final String tempDirectory;
  @override
  FutureOr<Map<String, DetectedFace>> build() async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    tempDirectory = directories.temp.pathString;
    return {};
  }

  void upsertFace(DetectedFace face) {
    state = AsyncData({...state.value!, face.identity: face});
  }

  void upsertFaces(List<DetectedFace> faces) {
    state = AsyncData({
      ...state.asData?.value ?? {},
      ...{for (final e in faces) e.identity: e},
    });
  }

  void removeFace(DetectedFace face) {
    final current = {...(state.asData?.value ?? {})}..remove(face.identity);
    state = AsyncData(current);
  }

  DetectedFace? getFace(String identity) {
    final map = state.asData?.value ?? {};

    return map[identity];
  }

  Future<bool> registerFace(
    CLServer server,
    CLSocket session,
    String identity,
    String name,
  ) async {
    final face = getFace(identity);
    if (face == null) return false;

    final facePath = await session.downloadFaceImage(identity);
    final vectorPath = await session.downloadFaceVector(identity);

    if (facePath == null || vectorPath == null) {
      return false;
    }

    final reply = await server.post(
      '/store/face/register/person/new/$name',
      filesFields: {
        'face': [facePath],
        'vector': [vectorPath],
      },
    );
    await reply.when(
      validResponse: (result) async {
        final updatedFace = face.copyWith(
          registeredFace: () => RegisteredFace.fromJson(result as String),
        );
        upsertFace(updatedFace);
      },
      errorResponse: (e, {st}) async {
        print(e);
      },
    );

    return true;
  }

  Future<bool> associateFace(
    CLServer server,
    CLSocket session,
    String identity,
    RegisteredPerson person,
  ) async {
    final face = getFace(identity);
    if (face == null) return false;
    final facePath = await session.downloadFaceImage(identity);
    final vectorPath = await session.downloadFaceVector(identity);

    if (facePath == null || vectorPath == null) {
      return false;
    }
    return true;
  }
}
