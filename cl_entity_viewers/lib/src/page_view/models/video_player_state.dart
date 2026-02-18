// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

@immutable
class VideoPlayerState {
  const VideoPlayerState({
    this.path,
    this.controller,
    this.isInitialized = false,
    this.isBuffering = false,
    this.isHls = false,
  });
  final Uri? path;
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool isBuffering;
  final bool isHls;

  @override
  bool operator ==(covariant VideoPlayerState other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.controller == controller &&
        other.isInitialized == isInitialized &&
        other.isBuffering == isBuffering &&
        other.isHls == isHls;
  }

  @override
  int get hashCode =>
      path.hashCode ^
      controller.hashCode ^
      isInitialized.hashCode ^
      isBuffering.hashCode ^
      isHls.hashCode;

  VideoPlayerState copyWith({
    ValueGetter<Uri?>? path,
    ValueGetter<VideoPlayerController?>? controller,
    bool? isInitialized,
    bool? isBuffering,
    bool? isHls,
  }) {
    return VideoPlayerState(
      path: path != null ? path.call() : this.path,
      controller: controller != null ? controller.call() : this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isBuffering: isBuffering ?? this.isBuffering,
      isHls: isHls ?? this.isHls,
    );
  }
}
