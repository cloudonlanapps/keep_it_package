import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:flutter/material.dart';

@immutable
class FaceFileCache {
  const FaceFileCache({
    required this.face,
    required this.image,
    required this.vector,
  });
  final DetectedFace face;
  final String image;
  final String vector;

  FaceFileCache copyWith({DetectedFace? face, String? image, String? vector}) {
    return FaceFileCache(
      face: face ?? this.face,
      image: image ?? this.image,
      vector: vector ?? this.vector,
    );
  }

  @override
  bool operator ==(covariant FaceFileCache other) {
    if (identical(this, other)) return true;

    return other.face == face && other.image == image && other.vector == vector;
  }

  @override
  int get hashCode => face.hashCode ^ image.hashCode ^ vector.hashCode;

  @override
  String toString() =>
      'FaceFileCache(face: $face, image: $image, vector: $vector)';
}
