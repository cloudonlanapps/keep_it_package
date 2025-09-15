import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/providers/d_online_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face/detected_face.dart';
import '../models/face/registered_face.dart';
import 'f_faces.dart';

final detectedFaceProvider =
    AsyncNotifierProviderFamily<DetectedFaceNotifier, DetectedFace?, String>(
      DetectedFaceNotifier.new,
    );

class DetectedFaceNotifier extends FamilyAsyncNotifier<DetectedFace?, String> {
  @override
  FutureOr<DetectedFace?> build(String arg) {
    final faceMap = ref
        .watch(detectedFacesProvider)
        .whenOrNull(data: (data) => data);
    return faceMap?[arg];
  }

  Future<void> registerSelf(String name) async {
    final server = await ref.read(activeAIServerProvider.future);
    if (server == null) return;
    final face = state.asData?.value;
    if (face == null) return;

    final reply = await server.post(
      '/store/register_face/of/$name',
      filesFields: {
        'face': [face.imageCache],
        'vector': [face.vectorCache],
      },
    );
    await reply.when(
      validResponse: (result) async {
        final updatedFace = face.copyWith(
          registeredFace: () => RegisteredFace.fromJson(result as String),
        );
        ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
      },
      errorResponse: (e, {st}) async {
        //print(e);
      },
    );
  }
}
