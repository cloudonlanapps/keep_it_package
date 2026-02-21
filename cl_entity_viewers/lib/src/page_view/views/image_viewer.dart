import 'dart:developer' as dev;
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colan_widgets/colan_widgets.dart';

import '../models/uri_config.dart';
import '../providers/uri_config.dart';

class ImageViewer extends ConsumerWidget {
  const ImageViewer({
    required this.uri,
    required this.isLocked,
    required this.onLockPage,
    required this.hasGesture,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    super.key,
    this.fit,
  });

  final Uri uri;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;
  final bool keepAspectRatio;
  final BoxFit? fit;
  final bool hasGesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriConfigAsync = ref.watch(uriConfigurationProvider(uri));
    final mode = hasGesture
        ? ExtendedImageMode.gesture
        : ExtendedImageMode.none;
    // Default to BoxFit.contain to ensure consistent scaling with overlays
    final effectiveFit = fit ?? BoxFit.contain;

    dev.log(
      '[ImageViewer] Loading image:\n'
      '  uri: $uri\n'
      '  scheme: ${uri.scheme}',
      name: 'ImageViewer',
    );

    return uriConfigAsync.when(
      data: (uriConfig) {
        dev.log(
          '[ImageViewer] uriConfig ready, rendering image: $uri',
          name: 'ImageViewer',
        );
        return switch (uri.scheme) {
          'file' => ExtendedImage.file(
            File(
              uri.hasQuery
                  ? uri.replace(queryParameters: {}).toFilePath()
                  : uri.toFilePath(),
            ),
            width: double.infinity,
            height: double.infinity,
            fit: effectiveFit,
            mode: mode,
            initGestureConfigHandler: hasGesture
                ? initGestureConfigHandler
                : null,
          ),
          _ => ExtendedImage.network(
            uri.toString(),
            width: double.infinity,
            height: double.infinity,
            fit: effectiveFit,
            mode: mode,
            initGestureConfigHandler: hasGesture
                ? initGestureConfigHandler
                : null,
            cache: true,
          ),
        };
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }

  GestureConfig initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      inPageView: true,
      animationMaxScale: 10,
      minScale: 1,
      maxScale: 10,
      gestureDetailsIsChanged: (details) {
        if (details?.totalScale == null) return;
        onLockPage?.call(lock: details!.totalScale! > 1.0);
      },
    );
  }
}

class ImageFromState extends ConsumerWidget {
  const ImageFromState(
    this.state, {
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    required this.uriConfig,
    required this.mode,
    super.key,
    this.initGestureConfigHandler,
    this.fit,
  });
  final ExtendedImageState state;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;
  final bool keepAspectRatio;
  final UriConfig uriConfig;
  final ExtendedImageMode mode;
  final BoxFit? fit;
  final GestureConfig Function(ExtendedImageState)? initGestureConfigHandler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default to BoxFit.contain to ensure consistent scaling with overlays
    final effectiveFit = fit ?? BoxFit.contain;

    if (!keepAspectRatio) {
      return ExtendedImage(
        image: state.imageProvider,
        fit: effectiveFit,
        mode: mode,
        initGestureConfigHandler: initGestureConfigHandler,
      );
    }
    final imageInfo = state.extendedImageInfo;
    final width = imageInfo?.image.width.toDouble() ?? 1;
    final height = imageInfo?.image.height.toDouble() ?? 1;
    final aspectRatio = width / height;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: RotatedBox(
        quarterTurns: uriConfig.quarterTurns,
        child: ExtendedImage(
          image: state.imageProvider,
          fit: effectiveFit,
          mode: mode,
          initGestureConfigHandler: initGestureConfigHandler,
        ),
      ),
    );
  }
}
