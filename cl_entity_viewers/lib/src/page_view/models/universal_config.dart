// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// NOTE: isManuallyPaused is not persistant
@immutable
class UniversalConfiguration {
  const UniversalConfiguration({
    this.isAudioMuted = false,
    this.lastKnownVolume = 1.0,
    this.isManuallyPaused = false,
  });

  factory UniversalConfiguration.fromMap(Map<String, dynamic> map) {
    return UniversalConfiguration(
      isAudioMuted: (map['isAudioMuted'] ?? false) as bool,
      lastKnownVolume: (map['lastKnownVolume'] ?? 1.0) as double,
    );
  }

  factory UniversalConfiguration.fromJson(String source) =>
      UniversalConfiguration.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
  final bool isAudioMuted;
  final double lastKnownVolume;
  final bool isManuallyPaused;

  double get audioVolume => isAudioMuted ? 0.0 : lastKnownVolume;

  UniversalConfiguration copyWith({
    bool? isAudioMuted,
    double? lastKnownVolume,
    bool? isManuallyPaused,
  }) {
    return UniversalConfiguration(
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      lastKnownVolume: lastKnownVolume ?? this.lastKnownVolume,
      isManuallyPaused: isManuallyPaused ?? this.isManuallyPaused,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isAudioMuted': isAudioMuted,
      'lastKnownVolume': lastKnownVolume,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'UniversalConfiguration(isAudioMuted: $isAudioMuted, lastKnownVolume: $lastKnownVolume)';

  @override
  bool operator ==(covariant UniversalConfiguration other) {
    if (identical(this, other)) return true;

    return other.isAudioMuted == isAudioMuted &&
        other.lastKnownVolume == lastKnownVolume &&
        other.isManuallyPaused == isManuallyPaused;
  }

  @override
  int get hashCode =>
      isAudioMuted.hashCode ^
      lastKnownVolume.hashCode ^
      isManuallyPaused.hashCode;
}
