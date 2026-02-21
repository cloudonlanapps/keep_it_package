import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';

/// CustomPainter for drawing facial landmarks within a face bounding box.
///
/// Draws 5 landmark points: left eye, right eye, nose tip, mouth left, mouth right.
/// The landmarks are drawn relative to the face box coordinates.
class FaceLandmarksPainter extends CustomPainter {
  FaceLandmarksPainter({
    required this.landmarks,
    required this.faceBox,
    this.color = Colors.cyan,
    this.pointRadius = 3.0,
    this.drawConnections = false,
  });

  /// The facial landmarks data.
  final FaceLandmarksData landmarks;

  /// The face bounding box in normalized coordinates (0.0-1.0).
  /// Used to convert landmark positions relative to the box.
  final ({double x1, double y1, double x2, double y2}) faceBox;

  /// Color for the landmark points.
  final Color color;

  /// Radius of each landmark point.
  final double pointRadius;

  /// Whether to draw connection lines between landmarks.
  final bool drawConnections;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Calculate the face box dimensions
    final boxWidth = faceBox.x2 - faceBox.x1;
    final boxHeight = faceBox.y2 - faceBox.y1;

    // Convert normalized landmark to pixel position relative to the widget size.
    // Landmarks are in image coordinates, we need to convert them to box-relative.
    Offset toPixel(({double x, double y}) point) {
      // Convert from image-normalized to box-relative
      final relativeX = (point.x - faceBox.x1) / boxWidth;
      final relativeY = (point.y - faceBox.y1) / boxHeight;
      // Then to pixel coordinates
      return Offset(relativeX * size.width, relativeY * size.height);
    }

    final leftEyePos = toPixel(landmarks.leftEye);
    final rightEyePos = toPixel(landmarks.rightEye);
    final noseTipPos = toPixel(landmarks.noseTip);
    final mouthLeftPos = toPixel(landmarks.mouthLeft);
    final mouthRightPos = toPixel(landmarks.mouthRight);

    // Draw connection lines if enabled
    if (drawConnections) {
      // Eye line
      canvas.drawLine(leftEyePos, rightEyePos, linePaint);
      // Nose to eyes
      canvas.drawLine(leftEyePos, noseTipPos, linePaint);
      canvas.drawLine(rightEyePos, noseTipPos, linePaint);
      // Nose to mouth
      canvas.drawLine(noseTipPos, mouthLeftPos, linePaint);
      canvas.drawLine(noseTipPos, mouthRightPos, linePaint);
      // Mouth line
      canvas.drawLine(mouthLeftPos, mouthRightPos, linePaint);
    }

    // Draw landmark points
    canvas.drawCircle(leftEyePos, pointRadius, paint);
    canvas.drawCircle(rightEyePos, pointRadius, paint);
    canvas.drawCircle(noseTipPos, pointRadius, paint);
    canvas.drawCircle(mouthLeftPos, pointRadius, paint);
    canvas.drawCircle(mouthRightPos, pointRadius, paint);
  }

  @override
  bool shouldRepaint(covariant FaceLandmarksPainter oldDelegate) {
    return landmarks != oldDelegate.landmarks ||
        faceBox != oldDelegate.faceBox ||
        color != oldDelegate.color ||
        pointRadius != oldDelegate.pointRadius ||
        drawConnections != oldDelegate.drawConnections;
  }
}
