import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:meta/meta.dart';

/// Data class representing face detection information.
///
/// This model provides a convenient representation of face data
/// with normalized coordinates for UI rendering.
@immutable
class FaceData {
  const FaceData({
    required this.id,
    required this.bbox,
    required this.confidence,
    this.landmarks,
    this.knownPersonId,
  });

  /// Create FaceData from SDK's FaceResponse.
  factory FaceData.fromFaceResponse(FaceResponse face) {
    return FaceData(
      id: face.id,
      bbox: (
        x1: face.bbox.x1,
        y1: face.bbox.y1,
        x2: face.bbox.x2,
        y2: face.bbox.y2,
      ),
      confidence: face.confidence,
      landmarks: FaceLandmarksData.fromFaceLandmarks(face.landmarks),
      knownPersonId: face.knownPersonId,
    );
  }

  /// Face ID.
  final int id;

  /// Bounding box (x1, y1, x2, y2) in normalized coordinates (0.0-1.0).
  /// x1, y1 is top-left, x2, y2 is bottom-right.
  final ({double x1, double y1, double x2, double y2}) bbox;

  /// Detection confidence score [0.0, 1.0].
  final double confidence;

  /// Optional facial landmarks.
  final FaceLandmarksData? landmarks;

  /// Known person ID if face recognition has been performed.
  final int? knownPersonId;

  /// Width of the bounding box in normalized coordinates.
  double get width => bbox.x2 - bbox.x1;

  /// Height of the bounding box in normalized coordinates.
  double get height => bbox.y2 - bbox.y1;

  /// Center X of the bounding box in normalized coordinates.
  double get centerX => (bbox.x1 + bbox.x2) / 2;

  /// Center Y of the bounding box in normalized coordinates.
  double get centerY => (bbox.y1 + bbox.y2) / 2;

  @override
  String toString() => 'FaceData('
      'id: $id, '
      'confidence: ${confidence.toStringAsFixed(3)}, '
      'bbox: (${bbox.x1.toStringAsFixed(3)}, ${bbox.y1.toStringAsFixed(3)}, '
      '${bbox.x2.toStringAsFixed(3)}, ${bbox.y2.toStringAsFixed(3)}), '
      'knownPersonId: $knownPersonId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaceData &&
        other.id == id &&
        other.bbox == bbox &&
        other.confidence == confidence &&
        other.landmarks == landmarks &&
        other.knownPersonId == knownPersonId;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      bbox.hashCode ^
      confidence.hashCode ^
      landmarks.hashCode ^
      knownPersonId.hashCode;
}

/// Data class representing facial landmarks.
///
/// Contains five key facial feature points in normalized coordinates.
@immutable
class FaceLandmarksData {
  const FaceLandmarksData({
    required this.leftEye,
    required this.rightEye,
    required this.noseTip,
    required this.mouthLeft,
    required this.mouthRight,
  });

  /// Create FaceLandmarksData from SDK's FaceLandmarks.
  factory FaceLandmarksData.fromFaceLandmarks(FaceLandmarks landmarks) {
    return FaceLandmarksData(
      leftEye: (x: landmarks.leftEye[0], y: landmarks.leftEye[1]),
      rightEye: (x: landmarks.rightEye[0], y: landmarks.rightEye[1]),
      noseTip: (x: landmarks.noseTip[0], y: landmarks.noseTip[1]),
      mouthLeft: (x: landmarks.mouthLeft[0], y: landmarks.mouthLeft[1]),
      mouthRight: (x: landmarks.mouthRight[0], y: landmarks.mouthRight[1]),
    );
  }

  /// Left eye position (x, y) in normalized coordinates.
  final ({double x, double y}) leftEye;

  /// Right eye position (x, y) in normalized coordinates.
  final ({double x, double y}) rightEye;

  /// Nose tip position (x, y) in normalized coordinates.
  final ({double x, double y}) noseTip;

  /// Left mouth corner position (x, y) in normalized coordinates.
  final ({double x, double y}) mouthLeft;

  /// Right mouth corner position (x, y) in normalized coordinates.
  final ({double x, double y}) mouthRight;

  @override
  String toString() => 'FaceLandmarksData('
      'leftEye: (${leftEye.x.toStringAsFixed(3)}, ${leftEye.y.toStringAsFixed(3)}), '
      'rightEye: (${rightEye.x.toStringAsFixed(3)}, ${rightEye.y.toStringAsFixed(3)}), '
      'noseTip: (${noseTip.x.toStringAsFixed(3)}, ${noseTip.y.toStringAsFixed(3)}), '
      'mouthLeft: (${mouthLeft.x.toStringAsFixed(3)}, ${mouthLeft.y.toStringAsFixed(3)}), '
      'mouthRight: (${mouthRight.x.toStringAsFixed(3)}, ${mouthRight.y.toStringAsFixed(3)}))';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaceLandmarksData &&
        other.leftEye == leftEye &&
        other.rightEye == rightEye &&
        other.noseTip == noseTip &&
        other.mouthLeft == mouthLeft &&
        other.mouthRight == mouthRight;
  }

  @override
  int get hashCode =>
      leftEye.hashCode ^
      rightEye.hashCode ^
      noseTip.hashCode ^
      mouthLeft.hashCode ^
      mouthRight.hashCode;
}
