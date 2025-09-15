import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:content_store/content_store.dart';
import 'package:face_it_desktop/models/face/registered_face.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

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
    String sessionId,
    String identity,
    String name,
  ) async {
    final face = getFace(identity);
    if (face == null) return false;
    // ignore: unused_local_variable for now!
    final files = await filesFromSession(server, sessionId, identity);

    if (files != null) {
      final reply = await server.post(
        '/store/face/register/person/new/$name',
        filesFields: {
          'face': [files[0]],
          'vector': [files[1]],
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
    return false;
  }

  Future<bool> associateFace(
    CLServer server,
    String sessionId,
    String identity,
    RegisteredPerson person,
  ) async {
    final face = getFace(identity);
    if (face == null) return false;
    // ignore: unused_local_variable for now
    final files = await filesFromSession(server, sessionId, identity);
    return true;
  }

  Future<List<String>?> filesFromSession(
    CLServer server,
    String sessionId,
    String identity,
  ) async {
    final faceUrl = '/sessions/$sessionId/face/$identity';
    final vectorUrl = '/sessions/$sessionId/vector/$identity';

    final face = await downloadFile(
      server,
      sessionId,
      faceUrl,
      p.join(tempDirectory, identity),
    );
    final vector = await downloadFile(
      server,
      sessionId,
      vectorUrl,
      p.join(tempDirectory, identity.replaceAll(RegExp(r'\.png$'), '.npy')),
    );
    if (face == null || vector == null) return null;

    return [face, vector];
  }

  Future<String?> downloadFile(
    CLServer server,
    String sessionId,
    String url,
    String targetFile,
  ) async {
    final response = await server.get(url, outputFileName: targetFile);

    return response.when(
      validResponse: (result) async {
        return result as String;
      },
      errorResponse: (_, {st}) async => null,
    );
  }
}
