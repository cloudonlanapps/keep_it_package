import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

/// Widget for viewing images using [ExtendedImage] for thumbnail/grid rendering.
///
/// This widget provides local rendering with support for file, asset, and network schemes.
/// It is intended for use in grid views and simple previews where interactive features
/// like zoom and face overlays are not required.
class ImageViewer extends StatelessWidget {
  const ImageViewer({
    required this.uri,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.onImageLoaded,
    this.fit = BoxFit.contain,
    super.key,
  });

  /// The URI of the image to display.
  final Uri uri;

  /// Builder for error state.
  final CLErrorView Function(Object, StackTrace) errorBuilder;

  /// Builder for loading state.
  final CLLoadingView Function() loadingBuilder;

  /// Callback when image has finished loading.
  final VoidCallback? onImageLoaded;

  /// How to fit the image into the available space.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (uri.scheme == 'file') {
      final filePath = uri.hasQuery
          ? uri.replace(queryParameters: {}).toFilePath()
          : uri.toFilePath();
      return ExtendedImage.file(
        File(filePath),
        fit: fit,
        mode: ExtendedImageMode.none,
        loadStateChanged: (state) => _buildLoadStateWidget(context, state),
      );
    } else if (uri.scheme == 'asset' || uri.scheme.isEmpty) {
      final assetPath = uri.scheme == 'asset' ? uri.path : uri.toString();
      return ExtendedImage.asset(
        assetPath,
        fit: fit,
        mode: ExtendedImageMode.none,
        loadStateChanged: (state) => _buildLoadStateWidget(context, state),
      );
    } else {
      return ExtendedImage.network(
        uri.toString(),
        fit: fit,
        mode: ExtendedImageMode.none,
        loadStateChanged: (state) => _buildLoadStateWidget(context, state),
        cache: true,
      );
    }
  }

  Widget? _buildLoadStateWidget(
    BuildContext context,
    ExtendedImageState state,
  ) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        return loadingBuilder();
      case LoadState.completed:
        if (onImageLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onImageLoaded!());
        }
        return null;
      case LoadState.failed:
        return errorBuilder(
          state.lastException ?? Exception('Failed to load image'),
          StackTrace.current,
        );
    }
  }
}
