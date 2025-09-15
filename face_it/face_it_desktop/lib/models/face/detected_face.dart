import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:face_it_desktop/models/face/bbox.dart';
import 'package:face_it_desktop/models/face/landmarks.dart';
import 'package:flutter/material.dart';

import 'guessed_face.dart';
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
    required this.guesses,
    required this.status,
    this.landmarks,
    this.registeredFace,
    this.loading = false,
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
      guesses: map['guesses'] != null
          ? (map['guesses'] as List<dynamic>)
                .map((e) => GuessedFace.fromMap(e as Map<String, dynamic>))
                .toList()
          : null,
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
  final List<GuessedFace>? guesses;
  final RecognitionStatus status;
  final bool loading;

  DetectedFace copyWith({
    BBox? bbox,
    ValueGetter<FaceLandmarks?>? landmarks,
    String? image,
    ValueGetter<RegisteredFace?>? registeredFace,
    ValueGetter<List<GuessedFace>?>? guesses,
    RecognitionStatus? status,
    bool? loading,
  }) {
    return DetectedFace(
      bbox: bbox ?? this.bbox,
      landmarks: landmarks != null ? landmarks.call() : this.landmarks,
      image: image ?? this.image,
      registeredFace: registeredFace != null
          ? registeredFace.call()
          : this.registeredFace,
      guesses: guesses != null ? guesses.call() : this.guesses,
      status: status ?? this.status,
      loading: loading ?? this.loading,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bbox': bbox.toMap()['data'],
      'landmarks': landmarks?.toMap()['data'],
      'image': image,
      'registeredFace': registeredFace?.toMap(),
      'guesses': guesses?.map((e) => e.toMap()).toList(),
      'status': status.label,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'DetectedFace(bbox: $bbox, landmarks: $landmarks, image: $image, registeredFace: $registeredFace, guesses: $guesses, status: $status, loading: $loading)';
  }

  @override
  bool operator ==(covariant DetectedFace other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.bbox == bbox &&
        other.landmarks == landmarks &&
        other.image == image &&
        other.registeredFace == registeredFace &&
        listEquals(other.guesses, guesses) &&
        other.status == status &&
        other.loading == loading;
  }

  @override
  int get hashCode {
    return bbox.hashCode ^
        landmarks.hashCode ^
        image.hashCode ^
        registeredFace.hashCode ^
        guesses.hashCode ^
        status.hashCode ^
        loading.hashCode;
  }

  String get identity => image;

  String formatName(String name) {
    return name
        .split(RegExp(r'\s+')) // split on spaces/tabs
        .map((word) {
          if (word.isEmpty) return word;
          final first = word.characters.first.toUpperCase();
          final rest = word.characters.skip(1).toString();
          return '$first$rest';
        })
        .join(' ');
  }

  String get label {
    final String label;
    if (registeredFace?.personName != null) {
      label = '${registeredFace?.personName}';
    } else if (guesses?[0].registeredFace.personName != null) {
      label = '${guesses?[0].registeredFace.personName} ?';
    } else {
      label = 'New Face';
    }
    return formatName(label);
  }
}
