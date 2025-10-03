import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face_box_preferences.dart';

final faceBoxPreferenceProvider =
    StateNotifierProvider<FaceBoxPreferenceNotifier, FaceBoxPreferences>((ref) {
      return FaceBoxPreferenceNotifier();
    });

class FaceBoxPreferenceNotifier extends StateNotifier<FaceBoxPreferences> {
  FaceBoxPreferenceNotifier() : super(const FaceBoxPreferences());

  void toggleShowFaces({required bool showFaces}) {
    state = state.copyWith(showFaces: showFaces);
  }

  void toggleShowUnknownFaces({required bool showUnknownFaces}) {
    state = state.copyWith(showUnknownFaces: showUnknownFaces);
  }

  void updateColor(int index) {
    if (index != state.colorIndex) {
      state = state.copyWith(colorIndex: index);
    }
  }
}
