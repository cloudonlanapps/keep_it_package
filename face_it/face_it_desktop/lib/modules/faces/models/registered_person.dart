import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class RegisteredPerson {
  const RegisteredPerson({
    required this.id,
    required this.name,
    required this.isHidden,
    required this.faces,
    this.keyFaceId,
  });

  factory RegisteredPerson.fromMap(Map<String, dynamic> map) {
    try {
      return RegisteredPerson(
        id: map['id'] as int,
        name: map['name'] as String,
        keyFaceId: map['keyFaceId'] != null ? map['keyFaceId'] as String : null,
        isHidden: (map['isHidden'] as int) != 0,
        faces: (map['faces'] as List<dynamic>).cast<String>(),
      );
    } catch (e) {
      print('Here is the error!!');
      rethrow;
    }
  }

  factory RegisteredPerson.fromJson(String source) =>
      RegisteredPerson.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final String name;
  final String? keyFaceId;
  final bool isHidden;
  final List<String> faces;

  RegisteredPerson copyWith({
    int? id,
    String? name,
    ValueGetter<String?>? keyFaceId,
    bool? isHidden,
    List<String>? faces,
  }) {
    return RegisteredPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      keyFaceId: keyFaceId != null ? keyFaceId.call() : this.keyFaceId,
      isHidden: isHidden ?? this.isHidden,
      faces: faces ?? this.faces,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'keyFaceId': keyFaceId,
      'isHidden': isHidden ? 1 : 0,
      'faces': faces,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'RegisteredPerson(id: $id, name: $name, keyFaceId: $keyFaceId, isHidden: $isHidden, faces: $faces)';
  }

  @override
  bool operator ==(covariant RegisteredPerson other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.name == name &&
        other.keyFaceId == keyFaceId &&
        other.isHidden == isHidden &&
        listEquals(other.faces, faces);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        keyFaceId.hashCode ^
        isHidden.hashCode ^
        faces.hashCode;
  }
}
