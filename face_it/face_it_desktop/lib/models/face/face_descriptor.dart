import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'bbox.dart';
import 'landmarks.dart';

@immutable
class FaceDescriptor {
  const FaceDescriptor({
    required this.imageId,
    required this.identity,
    required this.bbox,
    required this.landmarks,
    required this.imageCache,
    required this.vectorCache,
  });

  factory FaceDescriptor.fromMap(Map<String, dynamic> map) {
    return FaceDescriptor(
      identity: map['identity'] as String,
      bbox: BBox.fromMap({'data': map['bbox']}),
      landmarks: FaceLandmarks.fromMap({'data': map['landmarks']}),
      imageCache: map['imageCache'] as String,
      vectorCache: map['vectorCache'] as String,
      imageId: map['imageId'] as String,
    );
  }

  factory FaceDescriptor.fromJson(String source) =>
      FaceDescriptor.fromMap(json.decode(source) as Map<String, dynamic>);
  final String imageId;
  final String identity;
  final BBox bbox;
  final FaceLandmarks landmarks;
  final String imageCache;
  final String vectorCache;

  FaceDescriptor copyWith({
    String? imageId,
    String? identity,
    BBox? bbox,
    FaceLandmarks? landmarks,
    String? imageCache,
    String? vectorCache,
  }) {
    return FaceDescriptor(
      imageId: imageId ?? this.imageId,
      identity: identity ?? this.identity,
      bbox: bbox ?? this.bbox,
      landmarks: landmarks ?? this.landmarks,
      imageCache: imageCache ?? this.imageCache,
      vectorCache: vectorCache ?? this.vectorCache,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identity': identity,
      'bbox': bbox.toMap()['data'],
      'landmarks': landmarks.toMap()['data'],
      'imageCache': imageCache,
      'vectorCache': vectorCache,
      'imageId': imageId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'FaceDescriptor(imageId: $imageId, identity: $identity, bbox: $bbox, landmarks: $landmarks, imageCache: $imageCache, vectorCache: $vectorCache)';
  }

  @override
  bool operator ==(covariant FaceDescriptor other) {
    if (identical(this, other)) return true;

    return other.imageId == imageId &&
        other.identity == identity &&
        other.bbox == bbox &&
        other.landmarks == landmarks &&
        other.imageCache == imageCache &&
        other.vectorCache == vectorCache;
  }

  @override
  int get hashCode {
    return imageId.hashCode ^
        identity.hashCode ^
        bbox.hashCode ^
        landmarks.hashCode ^
        imageCache.hashCode ^
        vectorCache.hashCode;
  }
}
