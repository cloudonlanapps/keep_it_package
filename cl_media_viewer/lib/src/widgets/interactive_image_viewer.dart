import 'dart:io' show File;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/interactive_face.dart';
import 'interactive_face_box.dart';

/// A standalone, self-contained widget for viewing images with interactive face overlays.
///
/// This widget:
/// - Displays an image from a URI
/// - Overlays interactive face bounding boxes that track with zoom/pan
/// - Handles keyboard shortcuts (1-9) to trigger face callbacks
/// - Supports tap, long-press, and right-click on faces
///
/// Everything inside [InteractiveViewer] transforms together, ensuring faces
/// always align with the image during zoom and pan operations.
class InteractiveImageViewer extends StatefulWidget {
  const InteractiveImageViewer({
    required this.imageData,
    this.enableZoom = true,
    this.minScale = 1.0,
    this.maxScale = 10.0,
    this.showFaceNumbers = true,
    this.defaultFaceBoxColor = Colors.green,
    this.faceBoxWidth = 2.0,
    this.selectedFaceId,
    this.onTap,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  /// The image data including URI, dimensions, and faces.
  final InteractiveImageData imageData;

  /// Whether to enable zoom/pan gestures.
  final bool enableZoom;

  /// Minimum zoom scale.
  final double minScale;

  /// Maximum zoom scale.
  final double maxScale;

  /// Whether to show face numbers (1, 2, 3, etc.) on face boxes.
  final bool showFaceNumbers;

  /// Default color for face bounding boxes.
  final Color defaultFaceBoxColor;

  /// Width of face bounding box borders.
  final double faceBoxWidth;

  /// ID of the currently selected face (if any).
  final int? selectedFaceId;

  /// Called when the image is tapped (not on a face).
  final VoidCallback? onTap;

  /// Builder for error state.
  final Widget Function(Object error)? errorBuilder;

  /// Builder for loading state.
  final Widget Function()? loadingBuilder;

  @override
  State<InteractiveImageViewer> createState() => _InteractiveImageViewerState();
}

class _InteractiveImageViewerState extends State<InteractiveImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle keyboard events for face selection (1-9 keys).
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final faces = widget.imageData.faces;
    if (faces.isEmpty) return KeyEventResult.ignored;

    // Handle number keys 1-9 for face selection
    final keyLabel = event.logicalKey.keyLabel;
    if (keyLabel.length == 1) {
      final number = int.tryParse(keyLabel);
      if (number != null && number >= 1 && number <= 9) {
        final index = number - 1; // Convert to 0-indexed
        if (index < faces.length) {
          // Trigger the face's onTap callback with center of screen as position
          // (keyboard doesn't have a specific position, so we use a default)
          final screenCenter = MediaQuery.of(context).size.center(Offset.zero);
          faces[index].onTap?.call(screenCenter);
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final imageData = widget.imageData;
    final imageSize = imageData.size;

    // Build the image widget
    Widget imageWidget = _buildImageWidget();

    // Build the composite: image + faces in a fixed-size container
    Widget composite = SizedBox(
      width: imageSize.width,
      height: imageSize.height,
      child: Stack(
        children: [
          // Image fills the entire SizedBox
          Positioned.fill(child: imageWidget),

          // Face overlay boxes
          ...imageData.faces.asMap().entries.map((entry) {
            final index = entry.key;
            final face = entry.value;
            return InteractiveFaceBox(
              key: ValueKey(face.id),
              face: face,
              index: index,
              imageSize: imageSize,
              defaultBoxColor: widget.defaultFaceBoxColor,
              boxWidth: widget.faceBoxWidth,
              isSelected: face.id == widget.selectedFaceId,
              showFaceNumber: widget.showFaceNumbers,
            );
          }),
        ],
      ),
    );

    // Wrap in FittedBox to maintain aspect ratio
    composite = FittedBox(
      fit: BoxFit.contain,
      child: composite,
    );

    // Wrap in InteractiveViewer for zoom/pan
    if (widget.enableZoom) {
      composite = InteractiveViewer(
        transformationController: _transformationController,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: composite,
      );
    }

    // Wrap in GestureDetector for global tap
    composite = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: composite,
    );

    // Wrap in Focus for keyboard shortcuts
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: composite,
    );
  }

  Widget _buildImageWidget() {
    final uri = widget.imageData.uri;

    // Determine image source type
    if (uri.scheme == 'file') {
      return ExtendedImage.file(
        File(uri.toFilePath()),
        fit: BoxFit.fill,
        mode: ExtendedImageMode.none, // No gestures - InteractiveViewer handles
        loadStateChanged: _buildLoadStateWidget,
      );
    } else if (uri.scheme == 'asset' || uri.scheme.isEmpty) {
      // Treat as asset
      final assetPath = uri.scheme == 'asset' ? uri.path : uri.toString();
      return ExtendedImage.asset(
        assetPath,
        fit: BoxFit.fill,
        mode: ExtendedImageMode.none,
        loadStateChanged: _buildLoadStateWidget,
      );
    } else {
      // Network image
      return ExtendedImage.network(
        uri.toString(),
        fit: BoxFit.fill,
        mode: ExtendedImageMode.none,
        loadStateChanged: _buildLoadStateWidget,
      );
    }
  }

  Widget? _buildLoadStateWidget(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        if (widget.loadingBuilder != null) {
          return widget.loadingBuilder!();
        }
        return const Center(
          child: CircularProgressIndicator(),
        );

      case LoadState.completed:
        return null; // Use the default completed widget

      case LoadState.failed:
        final error =
            state.lastException ?? Exception('Failed to load image');
        if (widget.errorBuilder != null) {
          return widget.errorBuilder!(error);
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
    }
  }
}
