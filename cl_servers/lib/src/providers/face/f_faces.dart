import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/face/detected_face.dart';

final detectedFacesProvider =
    AsyncNotifierProvider<DetectedFacesNotifier, Map<String, DetectedFace>>(
      DetectedFacesNotifier.new,
    );

class DetectedFacesNotifier extends AsyncNotifier<Map<String, DetectedFace>> {
  @override
  FutureOr<Map<String, DetectedFace>> build() async {
    return {};
  }

  void upsertFace(DetectedFace face) {
    state = AsyncData({...state.value!, face.descriptor.identity: face});
  }

  void upsertFaces(List<DetectedFace> faces) {
    state = AsyncData({
      ...state.asData?.value ?? {},
      ...{for (final e in faces) e.descriptor.identity: e},
    });
  }

  void removeFace(DetectedFace face) {
    final current = {...(state.asData?.value ?? {})}
      ..remove(face.descriptor.identity);
    state = AsyncData(current);
  }
}
