import 'package:flutter/material.dart';

import '../models/interactive_face.dart';
import 'face_landmarks_painter.dart';

/// A widget that renders an interactive face bounding box.
///
/// This widget is positioned using normalized coordinates converted to pixels
/// based on the image size. It handles all gesture interactions (tap, long-press,
/// right-click) and optionally displays facial landmarks.
class InteractiveFaceBox extends StatefulWidget {
  const InteractiveFaceBox({
    required this.face,
    required this.index,
    required this.imageSize,
    this.defaultBoxColor = Colors.green,
    this.boxWidth = 2.0,
    this.selectedBoxColor = Colors.blue,
    this.isSelected = false,
    this.showFaceNumber = true,
    this.landmarkColor = Colors.cyan,
    this.landmarkRadius = 3.0,
    super.key,
  });

  /// The interactive face data.
  final InteractiveFace face;

  /// The index of this face in the list (0-based).
  final int index;

  /// The size of the image in pixels.
  final Size imageSize;

  /// Default color for the bounding box (used if face.boxColor is null).
  final Color defaultBoxColor;

  /// Width of the bounding box border.
  final double boxWidth;

  /// Color when the face is selected.
  final Color selectedBoxColor;

  /// Whether this face is currently selected.
  final bool isSelected;

  /// Whether to show the face number label.
  final bool showFaceNumber;

  /// Color for landmark points.
  final Color landmarkColor;

  /// Radius of landmark points.
  final double landmarkRadius;

  @override
  State<InteractiveFaceBox> createState() => _InteractiveFaceBoxState();
}

class _InteractiveFaceBoxState extends State<InteractiveFaceBox> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bbox = widget.face.bbox;

    // Convert normalized coordinates to pixel coordinates
    final left = bbox.x1 * widget.imageSize.width;
    final top = bbox.y1 * widget.imageSize.height;
    final width = (bbox.x2 - bbox.x1) * widget.imageSize.width;
    final height = (bbox.y2 - bbox.y1) * widget.imageSize.height;

    // Don't render if dimensions are invalid
    if (width <= 0 || height <= 0) {
      return const SizedBox.shrink();
    }

    // Determine box color based on state
    Color boxColor = widget.face.boxColor ?? widget.defaultBoxColor;
    if (widget.isSelected) {
      boxColor = widget.selectedBoxColor;
    } else if (_isHovering) {
      boxColor = boxColor.withValues(alpha: 0.8);
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.face.onTap != null
              ? (details) => widget.face.onTap!(details.globalPosition)
              : null,
          onDoubleTapDown: widget.face.onDoubleTap != null
              ? (details) => widget.face.onDoubleTap!(details.globalPosition)
              : null,
          onLongPressStart: widget.face.onLongPress != null
              ? (details) => widget.face.onLongPress!(details.globalPosition)
              : null,
          onSecondaryTapUp: widget.face.onSecondaryTap != null
              ? (details) =>
                  widget.face.onSecondaryTap!(details.globalPosition)
              : null,
          child: _buildFaceVisual(boxColor, width, height),
        ),
      ),
    );
  }

  Widget _buildFaceVisual(Color boxColor, double width, double height) {
    Widget content = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: boxColor,
          width: widget.boxWidth,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: widget.face.showLandmarks && widget.face.landmarks != null
          ? CustomPaint(
              painter: FaceLandmarksPainter(
                landmarks: widget.face.landmarks!,
                faceBox: widget.face.bbox,
                color: widget.landmarkColor,
                pointRadius: widget.landmarkRadius,
              ),
            )
          : null,
    );

    // Add face number label if enabled
    if (widget.showFaceNumber) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            left: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: boxColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${widget.index + 1}', // 1-indexed for display
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Add label if provided
    if (widget.face.label != null) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            left: 0,
            right: 0,
            bottom: -18,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.face.label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }
}
