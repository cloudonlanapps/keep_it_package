import 'dart:async';

import 'package:content_store/content_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face/detected_face.dart';

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
}
