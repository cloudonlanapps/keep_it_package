// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class FaceBoxPreferences {
  const FaceBoxPreferences({this.enabled = true, this.colorIndex = 0});
  final bool enabled;
  final int colorIndex;

  FaceBoxPreferences copyWith({bool? enabled, int? colorIndex}) {
    return FaceBoxPreferences(
      enabled: enabled ?? this.enabled,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  bool operator ==(covariant FaceBoxPreferences other) {
    if (identical(this, other)) return true;

    return other.enabled == enabled && other.colorIndex == colorIndex;
  }

  @override
  int get hashCode => enabled.hashCode ^ colorIndex.hashCode;

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
}
