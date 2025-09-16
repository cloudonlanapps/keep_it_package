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
    required this.imageCache,
    required this.vectorCache,
    required this.notAFace,
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
                .map((e) => GuessedPerson.fromMap(e as Map<String, dynamic>))
                .toList()
          : null,
      notAFace: (map['imageCache'] as int) != 0,
      imageCache: map['imageCache'] as String,
      vectorCache: map['vectorCache'] as String,
    );
  }

  factory DetectedFace.fromJson(String source) =>
      DetectedFace.fromMap(json.decode(source) as Map<String, dynamic>);
  final BBox bbox;
  final FaceLandmarks? landmarks;
  final String image;
  final RegisteredFace? registeredFace;
  final List<GuessedPerson>? guesses;
  final bool notAFace;
  final bool loading;
  final String imageCache;
  final String vectorCache;

  DetectedFace copyWith({
    BBox? bbox,
    ValueGetter<FaceLandmarks?>? landmarks,
    String? image,
    ValueGetter<RegisteredFace?>? registeredFace,
    ValueGetter<List<GuessedPerson>?>? guesses,
    bool? notAFace,
    bool? loading,
    String? imageCache,
    String? vectorCache,
  }) {
    return DetectedFace(
      bbox: bbox ?? this.bbox,
      landmarks: landmarks != null ? landmarks.call() : this.landmarks,
      image: image ?? this.image,
      registeredFace: registeredFace != null
          ? registeredFace.call()
          : this.registeredFace,
      guesses: guesses != null ? guesses.call() : this.guesses,
      notAFace: notAFace ?? this.notAFace,
      loading: loading ?? this.loading,
      imageCache: imageCache ?? this.imageCache,
      vectorCache: vectorCache ?? this.vectorCache,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bbox': bbox.toMap()['data'],
      'landmarks': landmarks?.toMap()['data'],
      'image': image,
      'registeredFace': registeredFace?.toMap(),
      'guesses': guesses?.map((e) => e.toMap()).toList(),
      'notAFace': notAFace ? 1 : 0,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'DetectedFace(bbox: $bbox, landmarks: $landmarks, image: $image, registeredFace: $registeredFace, guesses: $guesses, notAFace: $notAFace, loading: $loading, imageCache: $imageCache, vectorCache: $vectorCache)';
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
        other.notAFace == notAFace &&
        other.loading == loading &&
        other.imageCache == imageCache &&
        other.vectorCache == vectorCache;
  }

  @override
  int get hashCode {
    return bbox.hashCode ^
        landmarks.hashCode ^
        image.hashCode ^
        registeredFace.hashCode ^
        guesses.hashCode ^
        notAFace.hashCode ^
        loading.hashCode ^
        imageCache.hashCode ^
        vectorCache.hashCode;
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
    } else if ((guesses?.isNotEmpty ?? false) && guesses?[0].person != null) {
      label =
          '${guesses?[0].person.name} (${guesses?[0].confidencePercentage})%';
    } else {
      label = 'New Face';
    }
    return formatName(label);
  }
}
