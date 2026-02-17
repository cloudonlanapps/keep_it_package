import 'dart:async';

import 'package:flutter/material.dart';
import 'package:colan_widgets/colan_widgets.dart';

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
    this.onLockPage,
    this.autoStart = false,
    this.autoPlay = false,
    this.isLocked = true,
    super.key,
    this.previewUri,
    this.hasGesture = true,
    this.fit,
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
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: switch (mime) {
        (_) when mime.startsWith('image') => ImageViewer(
          uri: uri,
          isLocked: isLocked,
          onLockPage: onLockPage,
          keepAspectRatio: keepAspectRatio,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          hasGesture: hasGesture,
          fit: fit,
        ),
        (_) when mime.startsWith('video') => VideoPlayer(
          uri: uri,
          keepAspectRatio: keepAspectRatio,
          errorBuilder: errorBuilder,
          loadingBuilder: () {
            if (previewUri != null) {
              return CLLoadingView.custom(
                child: ImageViewer(
                  uri: previewUri!,
                  errorBuilder: errorBuilder,
                  loadingBuilder: loadingBuilder,
                  keepAspectRatio: keepAspectRatio,
                  isLocked: true,
                  onLockPage: onLockPage,
                  hasGesture: false,
                  fit: fit,
                ),
              );
            }
            return CLLoadingView.custom(
              child: const CircularProgressIndicator(color: Colors.white),
            );
          },
        ),
        _ => runZonedGuarded(() {
          throw Exception('unsupported MIME');
        }, errorBuilder)!,
      },
    );
  }
}
