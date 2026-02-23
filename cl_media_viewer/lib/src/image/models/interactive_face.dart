import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';

/// Callback signature for gesture events with position information.
typedef GesturePositionCallback = void Function(Offset globalPosition);

/// Interactive face data with per-face callbacks.
///
/// Wraps [FaceData] from cl_basic_types and adds interaction callbacks
/// that are defined at the data level, making the widget self-contained.
///
/// All gesture callbacks receive the global position of the tap/press,
/// which can be used for positioning context menus or tooltips.
@immutable
class InteractiveFace {
  const InteractiveFace({
    required this.data,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.boxColor,
    this.showLandmarks = false,
    this.label,
  });

  /// The underlying face data (bbox, landmarks, etc.).
  final FaceData data;

  /// Called when the face box is tapped.
  /// Receives the global position of the tap.
  final GesturePositionCallback? onTap;

  /// Called when the face box is double-tapped.
  /// Receives the global position of the double-tap.
  final GesturePositionCallback? onDoubleTap;

  /// Called when the face box is long-pressed.
  /// Receives the global position of the long-press.
  final GesturePositionCallback? onLongPress;

  /// Called on right-click (desktop) or secondary tap.
  /// Receives the global position for context menu placement.
  final GesturePositionCallback? onSecondaryTap;

  /// Custom color for this face's bounding box.
  /// If null, the viewer's default color is used.
  final Color? boxColor;

  /// Whether to show landmarks for this face.
  final bool showLandmarks;

  /// Optional label to display (e.g., person name).
  final String? label;

  /// Convenience getter for the bounding box.
  ({double x1, double y1, double x2, double y2}) get bbox => data.bbox;

  /// Convenience getter for landmarks.
  FaceLandmarksData? get landmarks => data.landmarks;

  /// Face ID from the underlying data.
  int get id => data.id;

  /// Detection confidence score.
  double get confidence => data.confidence;

  /// Width of the bounding box in normalized coordinates.
  double get width => data.width;

  /// Height of the bounding box in normalized coordinates.
  double get height => data.height;

  @override
  String toString() => 'InteractiveFace(id: $id, label: $label, '
      'hasCallbacks: ${onTap != null || onLongPress != null})';
}

/// Input data for [InteractiveImageViewer].
///
/// Contains the image URI, dimensions, and list of interactive faces.
@immutable
class InteractiveImageData {
  const InteractiveImageData({
    required this.uri,
    required this.width,
    required this.height,
    this.faces = const [],
  });

  /// URI of the image to display.
  final Uri uri;

  /// Original width of the image in pixels.
  final int width;

  /// Original height of the image in pixels.
  final int height;

  /// List of faces to overlay on the image.
  final List<InteractiveFace> faces;

  /// Aspect ratio of the image (width / height).
  double get aspectRatio => width / height;

  /// Size as a Flutter Size object.
  Size get size => Size(width.toDouble(), height.toDouble());

  @override
  String toString() => 'InteractiveImageData(uri: $uri, '
      'size: ${width}x$height, faces: ${faces.length})';
}
