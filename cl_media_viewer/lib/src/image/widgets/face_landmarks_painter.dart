import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';

/// CustomPainter that renders facial landmarks within a face bounding box.
///
/// Landmarks are drawn as small circles at the five key facial feature points:
/// left eye, right eye, nose tip, mouth left, and mouth right.
class FaceLandmarksPainter extends CustomPainter {
  FaceLandmarksPainter({
    required this.landmarks,
    required this.faceBox,
    this.color = Colors.cyan,
    this.pointRadius = 3.0,
  });

  /// The facial landmarks data in normalized image coordinates.
  final FaceLandmarksData landmarks;

  /// The face bounding box in normalized coordinates.
  /// Used to convert landmark positions to local coordinates within the face box.
  final ({double x1, double y1, double x2, double y2}) faceBox;

  /// Color of the landmark points.
  final Color color;

  /// Radius of each landmark point.
  final double pointRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw each landmark point
    _drawLandmark(canvas, size, landmarks.leftEye, paint);
    _drawLandmark(canvas, size, landmarks.rightEye, paint);
    _drawLandmark(canvas, size, landmarks.noseTip, paint);
    _drawLandmark(canvas, size, landmarks.mouthLeft, paint);
    _drawLandmark(canvas, size, landmarks.mouthRight, paint);
  }

  /// Converts a landmark from image-normalized coordinates to local face box coordinates.
  void _drawLandmark(
    Canvas canvas,
    Size size,
    ({double x, double y}) point,
    Paint paint,
  ) {
    // Calculate the width and height of the face box in normalized coords
    final boxWidth = faceBox.x2 - faceBox.x1;
    final boxHeight = faceBox.y2 - faceBox.y1;

    // Avoid division by zero
    if (boxWidth <= 0 || boxHeight <= 0) return;

    // Convert from image-normalized to box-relative (0-1 within the box)
    final relativeX = (point.x - faceBox.x1) / boxWidth;
    final relativeY = (point.y - faceBox.y1) / boxHeight;

    // Convert to pixel coordinates within this widget
    final pixelX = relativeX * size.width;
    final pixelY = relativeY * size.height;

    canvas.drawCircle(Offset(pixelX, pixelY), pointRadius, paint);
  }

  @override
  bool shouldRepaint(FaceLandmarksPainter oldDelegate) {
    return landmarks != oldDelegate.landmarks ||
        faceBox != oldDelegate.faceBox ||
        color != oldDelegate.color ||
        pointRadius != oldDelegate.pointRadius;
  }
}
