import 'dart:convert';

import 'package:face_it_desktop/models/bbox.dart';
import 'package:face_it_desktop/models/landmarks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Face {
  const Face({required this.image, required this.bbox, this.landmarks});

  factory Face.fromMap(Map<String, dynamic> map) {
    return Face(
      image: map['image'] as String,
      bbox: BBox.fromMap({'data': map['bbox']}),
      landmarks: map['landmarks'] != null
          ? FaceLandmarks.fromMap({'data': map['landmarks']})
          : null,
    );
  }

  factory Face.fromJson(String source) =>
      Face.fromMap(json.decode(source) as Map<String, dynamic>);

  final BBox bbox;
  final FaceLandmarks? landmarks;
  final String image;

  Face copyWith({
    BBox? bbox,
    ValueGetter<FaceLandmarks?>? landmarks,
    String? image,
  }) {
    return Face(
      bbox: bbox ?? this.bbox,
      landmarks: landmarks != null ? landmarks.call() : this.landmarks,
      image: image ?? this.image,
    );
  }

  @override
  String toString() =>
      'Face(bbox: $bbox, landmarks: $landmarks, image: $image)';

  @override
  bool operator ==(covariant Face other) {
    if (identical(this, other)) return true;

    return other.bbox == bbox &&
        other.landmarks == landmarks &&
        other.image == image;
  }

  @override
  int get hashCode => bbox.hashCode ^ landmarks.hashCode ^ image.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'bbox': bbox.toMap()['data'],
      'landmarks': landmarks?.toMap()['data'],
    };
  }

  String toJson() => json.encode(toMap());
}
