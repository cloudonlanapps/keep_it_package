import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'registered_person.dart';

@immutable
class GuessedPerson {
  const GuessedPerson({required this.person, required this.confidence});

  factory GuessedPerson.fromMap(Map<String, dynamic> map) {
    return GuessedPerson(
      person: RegisteredPerson.fromMap(map['person'] as Map<String, dynamic>),
      confidence: map['confidence'] as double,
    );
  }

  factory GuessedPerson.fromJson(String source) =>
      GuessedPerson.fromMap(json.decode(source) as Map<String, dynamic>);
  final RegisteredPerson person;
  final double confidence;

  GuessedPerson copyWith({RegisteredPerson? person, double? confidence}) {
    return GuessedPerson(
      person: person ?? this.person,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() => 'GuessedPerson(name: $person, confidence: $confidence)';

  @override
  bool operator ==(covariant GuessedPerson other) {
    if (identical(this, other)) return true;

    return other.person == person && other.confidence == confidence;
  }

  @override
  int get hashCode => person.hashCode ^ confidence.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'person': person.toMap(),
      'confidence': confidence,
    };
  }

  String toJson() => json.encode(toMap());

  int get confidencePercentage => (confidence * 100).toInt();
}
