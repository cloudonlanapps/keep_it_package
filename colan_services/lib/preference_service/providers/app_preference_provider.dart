import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings for controlling face overlay display.
@immutable
class FaceOverlaySettings {
  const FaceOverlaySettings({
    this.showBoxes = true,
    this.showLandmarks = true,
  });

  /// Whether to show face bounding boxes.
  final bool showBoxes;

  /// Whether to show facial landmarks (eyes, nose, mouth).
  final bool showLandmarks;

  /// Returns true if any overlay elements should be shown.
  bool get isEnabled => showBoxes || showLandmarks;

  FaceOverlaySettings copyWith({
    bool? showBoxes,
    bool? showLandmarks,
  }) {
    return FaceOverlaySettings(
      showBoxes: showBoxes ?? this.showBoxes,
      showLandmarks: showLandmarks ?? this.showLandmarks,
    );
  }

  @override
  String toString() =>
      'FaceOverlaySettings(showBoxes: $showBoxes, showLandmarks: $showLandmarks)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaceOverlaySettings &&
        other.showBoxes == showBoxes &&
        other.showLandmarks == showLandmarks;
  }

  @override
  int get hashCode => showBoxes.hashCode ^ showLandmarks.hashCode;
}

@immutable
class AppPreferences {
  const AppPreferences({
    required this.themeMode,
    this.pageSize = 12,
    this.faceOverlay = const FaceOverlaySettings(),
  });
  final ThemeMode themeMode;
  final int pageSize;
  final FaceOverlaySettings faceOverlay;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    int? pageSize,
    FaceOverlaySettings? faceOverlay,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      pageSize: pageSize ?? this.pageSize,
      faceOverlay: faceOverlay ?? this.faceOverlay,
    );
  }

  @override
  String toString() =>
      'AppPreferences(themeMode: $themeMode, pageSize: $pageSize, '
      'faceOverlay: $faceOverlay)';

  @override
  bool operator ==(covariant AppPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode &&
        other.pageSize == pageSize &&
        other.faceOverlay == faceOverlay;
  }

  @override
  int get hashCode =>
      themeMode.hashCode ^ pageSize.hashCode ^ faceOverlay.hashCode;
}

class AppPreferenceNotifier extends StateNotifier<AppPreferences> {
  AppPreferenceNotifier()
    : super(const AppPreferences(themeMode: ThemeMode.light));

  set themeMode(ThemeMode value) => state = state.copyWith(themeMode: value);
  ThemeMode get themeMode => state.themeMode;

  // Face overlay settings
  FaceOverlaySettings get faceOverlay => state.faceOverlay;

  void toggleFaceBoxes() {
    state = state.copyWith(
      faceOverlay: state.faceOverlay.copyWith(
        showBoxes: !state.faceOverlay.showBoxes,
      ),
    );
  }

  void toggleFaceLandmarks() {
    state = state.copyWith(
      faceOverlay: state.faceOverlay.copyWith(
        showLandmarks: !state.faceOverlay.showLandmarks,
      ),
    );
  }

  bool get showFaceBoxes => state.faceOverlay.showBoxes;

  set showFaceBoxes(bool value) {
    state = state.copyWith(
      faceOverlay: state.faceOverlay.copyWith(showBoxes: value),
    );
  }

  bool get showFaceLandmarks => state.faceOverlay.showLandmarks;

  set showFaceLandmarks(bool value) {
    state = state.copyWith(
      faceOverlay: state.faceOverlay.copyWith(showLandmarks: value),
    );
  }

  void enableAllFaceOverlays() {
    state = state.copyWith(faceOverlay: const FaceOverlaySettings());
  }

  void disableAllFaceOverlays() {
    state = state.copyWith(
      faceOverlay: const FaceOverlaySettings(
        showBoxes: false,
        showLandmarks: false,
      ),
    );
  }
}

final appPreferenceProvider =
    StateNotifierProvider<AppPreferenceNotifier, AppPreferences>((ref) {
      return AppPreferenceNotifier();
    });
