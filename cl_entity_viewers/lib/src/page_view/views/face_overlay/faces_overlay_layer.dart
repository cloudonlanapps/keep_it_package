import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';

import 'face_box_overlay.dart';

/// Widget that creates the full overlay layer containing all face boxes.
///
/// This widget uses a [LayoutBuilder] to calculate display scaling
/// and positions face boxes while maintaining aspect ratio.
class FacesOverlayLayer extends StatelessWidget {
  const FacesOverlayLayer({
    required this.faces,
    required this.imageWidth,
    required this.imageHeight,
    required this.entityId,
    this.showBoxes = true,
    this.showLandmarks = true,
    this.boxColor = Colors.green,
    this.boxWidth = 2.0,
    this.landmarkColor = Colors.cyan,
    this.landmarkRadius = 3.0,
    this.onFaceTapped,
    super.key,
  });

  /// Entity ID this overlay belongs to (for debugging and widget keying).
  final int entityId;

  /// List of faces to display.
  final List<FaceData> faces;

  /// Original image width in pixels.
  final int imageWidth;

  /// Original image height in pixels.
  final int imageHeight;

  /// Whether to show face bounding boxes.
  final bool showBoxes;

  /// Whether to show facial landmarks.
  final bool showLandmarks;

  /// Color of the bounding boxes.
  final Color boxColor;

  /// Width of the bounding box borders.
  final double boxWidth;

  /// Color of the landmark points.
  final Color landmarkColor;

  /// Radius of the landmark points.
  final double landmarkRadius;

  /// Callback when a face is tapped.
  final void Function(FaceData face)? onFaceTapped;

  @override
  Widget build(BuildContext context) {
    if (faces.isEmpty || !showBoxes && !showLandmarks) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the display size while maintaining aspect ratio
        final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageSize = Size(imageWidth.toDouble(), imageHeight.toDouble());

        // Calculate scale to fit the image within the container
        final scaleX = containerSize.width / imageSize.width;
        final scaleY = containerSize.height / imageSize.height;
        final scale = math.min(scaleX, scaleY);

        // Calculate the displayed image size
        final displayWidth = imageSize.width * scale;
        final displayHeight = imageSize.height * scale;

        // Calculate offset for centering the image
        final offsetX = (containerSize.width - displayWidth) / 2;
        final offsetY = (containerSize.height - displayHeight) / 2;

        final displaySize = Size(displayWidth, displayHeight);

        dev.log(
          'FacesOverlayLayer for ENTITY $entityId:\n'
          '  containerSize: $containerSize\n'
          '  imageSize: $imageSize (original: ${imageWidth}x$imageHeight)\n'
          '  scale: $scale (scaleX=$scaleX, scaleY=$scaleY)\n'
          '  displaySize: $displaySize\n'
          '  offset: ($offsetX, $offsetY)\n'
          '  faces: ${faces.length}',
          name: 'FaceOverlay',
        );

        // Log face positions for debugging
        for (final face in faces) {
          final bbox = face.bbox;
          dev.log(
            '  Face ${face.id}: '
            'normalized=(${bbox.x1.toStringAsFixed(3)}, ${bbox.y1.toStringAsFixed(3)}) -> '
            '(${bbox.x2.toStringAsFixed(3)}, ${bbox.y2.toStringAsFixed(3)}), '
            'pixel=(${(bbox.x1 * displayWidth).toStringAsFixed(0)}, ${(bbox.y1 * displayHeight).toStringAsFixed(0)}) -> '
            '(${(bbox.x2 * displayWidth).toStringAsFixed(0)}, ${(bbox.y2 * displayHeight).toStringAsFixed(0)})',
            name: 'FaceOverlay',
          );
        }

        return Stack(
          children: [
            // Offset container to match the centered image position
            Positioned(
              left: offsetX,
              top: offsetY,
              width: displayWidth,
              height: displayHeight,
              child: Stack(
                children: faces.map((face) {
                  return FaceBoxOverlay(
                    face: face,
                    displaySize: displaySize,
                    showBox: showBoxes,
                    showLandmarks: showLandmarks,
                    boxColor: boxColor,
                    boxWidth: boxWidth,
                    landmarkColor: landmarkColor,
                    landmarkRadius: landmarkRadius,
                    onTap: onFaceTapped != null ? () => onFaceTapped!(face) : null,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
