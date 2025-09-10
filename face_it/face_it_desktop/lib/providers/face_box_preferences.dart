import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face_box_preferences.dart';

final faceBoxPreferenceProvider =
    StateNotifierProvider<FaceBoxPreferenceNotifier, FaceBoxPreferences>((ref) {
      return FaceBoxPreferenceNotifier();
    });

class FaceBoxPreferenceNotifier extends StateNotifier<FaceBoxPreferences> {
  FaceBoxPreferenceNotifier() : super(const FaceBoxPreferences());

  void toggle({required bool enable}) {
    state = state.copyWith(enabled: enable);
  }

  void updateColor(int index) {
    if (index != state.colorIndex) {
      state = state.copyWith(colorIndex: index);
    }
  }
}
