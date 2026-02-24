import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'image_viewer.dart';
import 'video_player.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({
    required this.heroTag,
    required this.uri,
    required this.mime,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    this.imageData,
    this.onLockPage,
    this.autoStart = false,
    this.autoPlay = false,
    this.isLocked = true,
    this.previewUri,
    this.hasGesture = true,
    this.onImageLoaded,
    super.key,
  });

  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final bool autoStart;
  final bool autoPlay;
  final Uri uri;
  final Uri? previewUri;

  final String heroTag;
  final String mime;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  final bool keepAspectRatio;
  final bool hasGesture;

  /// Optional image data with faces for image viewing.
  /// If not provided, a default InteractiveImageData is created from the URI.
  final InteractiveImageData? imageData;

  /// Callback when image has finished loading.
  final VoidCallback? onImageLoaded;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: switch (mime) {
        (_) when mime.startsWith('image') => ImageViewer(
          imageData: imageData ?? InteractiveImageData(uri: uri),
          onLockPage: onLockPage,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          hasGesture: hasGesture,
          onImageLoaded: onImageLoaded,
        ),
        (_) when mime.startsWith('video') => VideoPlayer(
          uri: uri,
          keepAspectRatio: keepAspectRatio,
          errorBuilder: errorBuilder,
          loadingBuilder: () {
            if (previewUri != null) {
              // Preview image for video - no faces, no gestures
              return CLLoadingView.custom(
                child: ImageViewer(
                  imageData: InteractiveImageData(uri: previewUri!),
                  errorBuilder: errorBuilder,
                  loadingBuilder: loadingBuilder,
                  hasGesture: false,
                ),
              );
            }
            return CLLoadingView.custom(
              child: const CircularProgressIndicator(color: Colors.white),
            );
          },
        ),
        _ => errorBuilder(
          Exception('unsupported MIME: $mime'),
          StackTrace.current,
        ),
      },
    );
  }
}
