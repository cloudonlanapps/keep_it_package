import 'dart:convert';

import 'package:face_it_desktop/models/bbox.dart';
import 'package:face_it_desktop/models/landmarks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'registered_face.dart';

enum RecognitionStatus {
  notChecked,
  notFound,
  recognized,
  confirmed;

  String get label => switch (this) {
    notChecked => 'UNCHECKED',
    notFound => 'NOT_FOUND',
    recognized => 'FOUND',
    confirmed => 'CONFIRMED',
  };
}

@immutable
class DetectedFace {
  const DetectedFace({
    required this.bbox,
    required this.image,
    required this.confidence,
    required this.status,
    this.landmarks,
    this.registeredFace,
  });

  factory DetectedFace.fromMap(Map<String, dynamic> map) {
    return DetectedFace(
      bbox: BBox.fromMap({'data': map['bbox']}),
      landmarks: map['landmarks'] != null
          ? FaceLandmarks.fromMap({'data': map['landmarks']})
          : null,
      image: map['image'] as String,
      registeredFace: map['registeredFace'] != null
          ? RegisteredFace.fromMap(
              map['registeredFace'] as Map<String, dynamic>,
            )
          : null,
      confidence: map['confidence'] != null ? map['confidence'] as double : 0,
      status: RecognitionStatus.values.firstWhere(
        (e) => (map['status'] as String) == e.label,
        orElse: () => throw ArgumentError('Invalid MediaType: ${map['name']}'),
      ),
    );
  }

  factory DetectedFace.fromJson(String source) =>
      DetectedFace.fromMap(json.decode(source) as Map<String, dynamic>);
  final BBox bbox;
  final FaceLandmarks? landmarks;
  final String image;
  final RegisteredFace? registeredFace;
  final double confidence;
  final RecognitionStatus status;

  DetectedFace copyWith({
    BBox? bbox,
    ValueGetter<FaceLandmarks?>? landmarks,
    String? image,
    ValueGetter<RegisteredFace?>? registeredFace,
    double? confidence,
    RecognitionStatus? status,
  }) {
    return DetectedFace(
      bbox: bbox ?? this.bbox,
      landmarks: landmarks != null ? landmarks.call() : this.landmarks,
      image: image ?? this.image,
      registeredFace: registeredFace != null
          ? registeredFace.call()
          : this.registeredFace,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bbox': bbox.toMap()['data'],
      'landmarks': landmarks?.toMap()['data'],
      'image': image,
      'registeredFace': registeredFace?.toMap(),
      'confidence': confidence,
      'status': status.label,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'DetectedFace(bbox: $bbox, landmarks: $landmarks, image: $image, registeredFace: $registeredFace, confidence: $confidence, status: $status)';
  }

  @override
  bool operator ==(covariant DetectedFace other) {
    if (identical(this, other)) return true;

    return other.bbox == bbox &&
        other.landmarks == landmarks &&
        other.image == image &&
        other.registeredFace == registeredFace &&
        other.confidence == confidence &&
        other.status == status;
  }

  @override
  int get hashCode {
    return bbox.hashCode ^
        landmarks.hashCode ^
        image.hashCode ^
        registeredFace.hashCode ^
        confidence.hashCode ^
        status.hashCode;
  }
}
