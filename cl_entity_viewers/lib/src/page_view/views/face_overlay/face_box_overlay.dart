import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';

import 'face_landmarks_painter.dart';

/// Widget that draws a single face bounding box with optional landmarks.
///
/// This widget is positioned using normalized coordinates and wrapped with
/// a [GestureDetector] for tap handling.
class FaceBoxOverlay extends StatelessWidget {
  const FaceBoxOverlay({
    required this.face,
    required this.displaySize,
    this.showBox = true,
    this.showLandmarks = true,
    this.boxColor = Colors.green,
    this.boxWidth = 2.0,
    this.landmarkColor = Colors.cyan,
    this.landmarkRadius = 3.0,
    this.onTap,
    super.key,
  });

  /// The face data containing bounding box and landmarks.
  final FaceData face;

  /// The display size of the image container.
  /// Used to convert normalized coordinates to pixel positions.
  final Size displaySize;

  /// Whether to show the bounding box.
  final bool showBox;

  /// Whether to show facial landmarks.
  final bool showLandmarks;

  /// Color of the bounding box.
  final Color boxColor;

  /// Width of the bounding box border.
  final double boxWidth;

  /// Color of the landmark points.
  final Color landmarkColor;

  /// Radius of the landmark points.
  final double landmarkRadius;

  /// Callback when the face box is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bbox = face.bbox;

    // Convert normalized coordinates to pixel coordinates
    final left = bbox.x1 * displaySize.width;
    final top = bbox.y1 * displaySize.height;
    final width = (bbox.x2 - bbox.x1) * displaySize.width;
    final height = (bbox.y2 - bbox.y1) * displaySize.height;

    // Don't render if dimensions are invalid
    if (width <= 0 || height <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: showBox
              ? BoxDecoration(
                  border: Border.all(
                    color: boxColor,
                    width: boxWidth,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: showLandmarks && face.landmarks != null
              ? CustomPaint(
                  painter: FaceLandmarksPainter(
                    landmarks: face.landmarks!,
                    faceBox: bbox,
                    color: landmarkColor,
                    pointRadius: landmarkRadius,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
