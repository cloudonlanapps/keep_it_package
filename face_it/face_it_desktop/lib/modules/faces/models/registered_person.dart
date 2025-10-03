import 'dart:convert';

import 'package:flutter/widgets.dart';

@immutable
class RegisteredPerson {
  const RegisteredPerson({
    required this.id,
    required this.name,
    required this.keyFaceId,
    required this.isHidden,
  });

  factory RegisteredPerson.fromMap(Map<String, dynamic> map) {
    return RegisteredPerson(
      id: map['id'] as int,
      name: map['name'] as String,
      keyFaceId: map['keyFaceId'] as String,
      isHidden: map['isHidden'] as int != 0,
    );
  }

  factory RegisteredPerson.fromJson(String source) =>
      RegisteredPerson.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final String name;
  final String keyFaceId;
  final bool isHidden;

  RegisteredPerson copyWith({
    int? id,
    String? name,
    String? keyFaceId,
    bool? isHidden,
  }) {
    return RegisteredPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      keyFaceId: keyFaceId ?? this.keyFaceId,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'keyFaceId': keyFaceId,
      'isHidden': isHidden ? 1 : 0,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'RegisteredPerson(id: $id, name: $name, keyFaceId: $keyFaceId, isHidden: $isHidden)';
  }

  @override
  bool operator ==(covariant RegisteredPerson other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.keyFaceId == keyFaceId &&
        other.isHidden == isHidden;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ keyFaceId.hashCode ^ isHidden.hashCode;
  }
}
