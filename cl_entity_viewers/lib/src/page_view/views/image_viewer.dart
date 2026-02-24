import 'package:cl_media_viewer/cl_media_viewer.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

/// Widget for viewing images with optional face overlays.
///
/// This widget wraps [InteractiveImageViewer] from cl_media_viewer,
/// providing integration with the page view system.
class ImageViewer extends StatelessWidget {
  const ImageViewer({
    required this.imageData,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.onLockPage,
    this.hasGesture = true,
    this.onTap,
    this.onImageLoaded,
    super.key,
  });

  /// The image data including URI, dimensions, and optional faces.
  final InteractiveImageData imageData;

  /// Builder for error state.
  final CLErrorView Function(Object, StackTrace) errorBuilder;

  /// Builder for loading state.
  final CLLoadingView Function() loadingBuilder;

  /// Called when zoom scale changes (scale > 1 means zoomed in).
  /// Used to lock page swiping when zoomed.
  final void Function({required bool lock})? onLockPage;

  /// Whether to enable zoom/pan gestures.
  final bool hasGesture;

  /// Called when the image area is tapped.
  final VoidCallback? onTap;

  /// Callback when image has finished loading.
  final VoidCallback? onImageLoaded;

  @override
  Widget build(BuildContext context) {
    return InteractiveImageViewer(
      imageData: imageData,
      enableZoom: hasGesture,
      minScale: 1.0,
      maxScale: 10.0,
      onTap: onTap,
      onScaleChanged: onLockPage != null
          ? (scale) => onLockPage!(lock: scale > 1.0)
          : null,
      errorBuilder: (error) => errorBuilder(error, StackTrace.current),
      loadingBuilder: loadingBuilder,
    );
  }
}
