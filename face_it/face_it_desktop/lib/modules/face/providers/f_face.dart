import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/detected_face.dart';
import '../../person/models/registered_person.dart';
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

  void confirmTaggedFace(RegisteredPerson person) {
    final face = state.asData?.value;
    if (face == null) return;
    final updatedFace = face.confirmTaggedFace(person);
    ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
  }

  void isAFace() {
    final face = state.asData?.value;
    if (face == null) return;
    final updatedFace = face.isAFace();
    ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
  }

  void markAsUnknown() {
    final face = state.asData?.value;
    if (face == null) return;
    final updatedFace = face.markAsUnknown();
    ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
  }

  void markNotAFace() {
    final face = state.asData?.value;
    if (face == null) return;
    final updatedFace = face.markNotAFace();
    ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
  }

  void rejectTaggedPerson(RegisteredPerson person) {
    final face = state.asData?.value;
    if (face == null) return;
    final updatedFace = face.rejectTaggedPerson(person);
    ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
  }

  void removeConfirmation() {
    final face = state.asData?.value;
    if (face == null) return;
    final updatedFace = face.removeConfirmation();
    ref.read(detectedFacesProvider.notifier).upsertFace(updatedFace);
  }
}
