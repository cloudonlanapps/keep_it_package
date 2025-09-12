import 'dart:convert';

import 'package:face_it_desktop/models/registered_face.dart';
import 'package:flutter/foundation.dart';

@immutable
class GuessedFace {
  const GuessedFace({required this.registeredFace, required this.confidence});

  factory GuessedFace.fromMap(Map<String, dynamic> map) {
    return GuessedFace(
      registeredFace: RegisteredFace.fromMap(
        map['registeredFace'] as Map<String, dynamic>,
      ),
      confidence: map['confidence'] as double,
    );
  }

  factory GuessedFace.fromJson(String source) =>
      GuessedFace.fromMap(json.decode(source) as Map<String, dynamic>);
  final RegisteredFace registeredFace;
  final double confidence;

  GuessedFace copyWith({RegisteredFace? registeredFace, double? confidence}) {
    return GuessedFace(
      registeredFace: registeredFace ?? this.registeredFace,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'registeredFace': registeredFace.toMap(),
      'confidence': confidence,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'GuessedFace(registeredFace: $registeredFace, confidence: $confidence)';

  @override
  bool operator ==(covariant GuessedFace other) {
    if (identical(this, other)) return true;

    return other.registeredFace == registeredFace &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => registeredFace.hashCode ^ confidence.hashCode;
}
