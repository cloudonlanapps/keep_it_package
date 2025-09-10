import 'dart:convert';

import 'package:face_it_desktop/models/bbox.dart';
import 'package:face_it_desktop/models/landmarks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Face {
  const Face({required this.bbox, this.landmarks});

  factory Face.fromMap(Map<String, dynamic> map) {
    return Face(
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

  Face copyWith({BBox? bbox, ValueGetter<FaceLandmarks?>? landmarks}) {
    return Face(
      bbox: bbox ?? this.bbox,
      landmarks: landmarks != null ? landmarks.call() : this.landmarks,
    );
  }

  @override
  String toString() => 'Face(bbox: $bbox, landmarks: $landmarks)';

  @override
  bool operator ==(covariant Face other) {
    if (identical(this, other)) return true;

    return other.bbox == bbox && other.landmarks == landmarks;
  }

  @override
  int get hashCode => bbox.hashCode ^ landmarks.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bbox': bbox.toMap()['data'],
      'landmarks': landmarks?.toMap()['data'],
    };
  }

  String toJson() => json.encode(toMap());
}
