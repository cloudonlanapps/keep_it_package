import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class Landmark {
  const Landmark({required this.x, required this.y, this.name});
  final String? name;
  final double x;
  final double y;

  Landmark copyWith({ValueGetter<String?>? name, double? x, double? y}) {
    return Landmark(
      name: name != null ? name.call() : this.name,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  String toString() => 'Landmark(name: $name, x: $x, y: $y)';

  @override
  bool operator ==(covariant Landmark other) {
    if (identical(this, other)) return true;

    return other.name == name && other.x == x && other.y == y;
  }

  @override
  int get hashCode => name.hashCode ^ x.hashCode ^ y.hashCode;
}

@immutable
class FaceLandmarks {
  FaceLandmarks(this._landmarks) {
    if (_landmarks.length != 5) {
      throw Exception(
        'A FaceLandmarks object must be initialized with exactly 5 landmarks.',
      );
    }
  }

  factory FaceLandmarks.fromMap(Map<String, dynamic> map) {
    try {
      final list = (map['data'] as List<dynamic>)
          .map((inner) => (inner as List).cast<double>())
          .toList();
      return FaceLandmarks.fromList(list);
    } catch (e) {
      throw ArgumentError('BBox must have exactly 5 entries.');
    }
  }

  factory FaceLandmarks.fromJson(String source) =>
      FaceLandmarks.fromMap(json.decode(source) as Map<String, dynamic>);

  factory FaceLandmarks.fromList(List<List<double>> points) {
    final landmarks = points.indexed.map((e) {
      final names = [
        'left_eye',
        'right_eye',
        'nose_tip',
        'left_mouth_corner',
        'right_mouth_corner',
      ];
      final index = e.$1;
      final p = e.$2;
      if (p.length != 2) {
        throw Exception('A point must have exactly 2 elements x and y');
      }
      return Landmark(x: p[0], y: p[1], name: names[index]);
    }).toList();
    return FaceLandmarks(landmarks);
  }
  final List<Landmark> _landmarks;

  List<Landmark> get landmarks => List.unmodifiable(_landmarks);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': _landmarks.map((x) => [x.x, x.y]).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'FaceLandmarks(_landmarks: $_landmarks)';

  @override
  bool operator ==(covariant FaceLandmarks other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other._landmarks, _landmarks);
  }

  @override
  int get hashCode => _landmarks.hashCode;

  FaceLandmarks copyWith({List<Landmark>? landmarks}) {
    return FaceLandmarks(landmarks ?? _landmarks);
  }
}
