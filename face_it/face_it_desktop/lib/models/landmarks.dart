import 'package:flutter/widgets.dart';

@immutable
class Landmark {
  const Landmark({required this.x, required this.y, this.name});
  final String? name;
  final double x;
  final double y;
}

class FaceLandmarks {
  FaceLandmarks(this._landmarks) {
    if (_landmarks.length != 5) {
      throw Exception(
        'A FaceLandmarks object must be initialized with exactly 5 landmarks.',
      );
    }
  }

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
}
