import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class RegisteredFace {
  const RegisteredFace({
    required this.id,
    required this.personId,
    required this.personName,
  });

  factory RegisteredFace.fromMap(Map<String, dynamic> map) {
    return RegisteredFace(
      id: map['id'] as String,
      personId: map['personId'] as int,
      personName: map['personName'] as String,
    );
  }

  factory RegisteredFace.fromJson(String source) =>
      RegisteredFace.fromMap(json.decode(source) as Map<String, dynamic>);
  final String id;
  final int personId;
  final String personName;

  RegisteredFace copyWith({String? id, int? personId, String? personName}) {
    return RegisteredFace(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'personId': personId,
      'personName': personName,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'RegisteredFace(id: $id, personId: $personId, personName: $personName)';

  @override
  bool operator ==(covariant RegisteredFace other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.personId == personId &&
        other.personName == personName;
  }

  @override
  int get hashCode => id.hashCode ^ personId.hashCode ^ personName.hashCode;
}
