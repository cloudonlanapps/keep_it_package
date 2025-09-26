import 'dart:convert';

import 'package:flutter/widgets.dart';

@immutable
class RegisteredPerson {
  const RegisteredPerson({
    required this.id,
    required this.name,
    required this.keyFaceId,
  });

  factory RegisteredPerson.fromMap(Map<String, dynamic> map) {
    return RegisteredPerson(
      id: map['id'] as int,
      name: map['name'] as String,
      keyFaceId: map['keyFaceId'] as String,
    );
  }

  factory RegisteredPerson.fromJson(String source) =>
      RegisteredPerson.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final String name;
  final String keyFaceId;

  RegisteredPerson copyWith({int? id, String? name, String? keyFaceId}) {
    return RegisteredPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      keyFaceId: keyFaceId ?? this.keyFaceId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'keyFaceId': keyFaceId};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'RegisteredPerson(id: $id, name: $name, keyFaceId: $keyFaceId)';

  @override
  bool operator ==(covariant RegisteredPerson other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.keyFaceId == keyFaceId;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ keyFaceId.hashCode;
}
