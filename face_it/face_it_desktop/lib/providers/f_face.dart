import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face/detected_face.dart';
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
}
