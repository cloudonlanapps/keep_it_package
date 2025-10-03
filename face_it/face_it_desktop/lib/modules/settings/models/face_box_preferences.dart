import 'package:flutter/material.dart';

@immutable
class FaceBoxPreferences {
  const FaceBoxPreferences({
    this.showFaces = true,
    this.colorIndex = 0,
    this.showUnknownFaces = false,
  });
  final bool showFaces;
  final int colorIndex;
  final bool showUnknownFaces;

  FaceBoxPreferences copyWith({
    bool? showFaces,
    int? colorIndex,
    bool? showUnknownFaces,
  }) {
    return FaceBoxPreferences(
      showFaces: showFaces ?? this.showFaces,
      colorIndex: colorIndex ?? this.colorIndex,
      showUnknownFaces: showUnknownFaces ?? this.showUnknownFaces,
    );
  }

  @override
  bool operator ==(covariant FaceBoxPreferences other) {
    if (identical(this, other)) return true;

    return other.showFaces == showFaces &&
        other.colorIndex == colorIndex &&
        other.showUnknownFaces == showUnknownFaces;
  }

  @override
  int get hashCode =>
      showFaces.hashCode ^ colorIndex.hashCode ^ showUnknownFaces.hashCode;

  // Dont add More than 8 colors
  static List<Color> colors = [
    const Color(0xFF39FF14),
    const Color(0xFF50C878), //Emerald Green
    const Color(0xFFFFBF00), // Amber
    const Color(0xFF00B0FF), //Sky Blue
    const Color(0xFFFF0000),
    const Color(0xFFFFFFFF),
  ];

  Color get color => colors[colorIndex];

  @override
  String toString() =>
      'FaceBoxPreferences(showFaces: $showFaces, colorIndex: $colorIndex, showUnknownFaces: $showUnknownFaces)';
}
