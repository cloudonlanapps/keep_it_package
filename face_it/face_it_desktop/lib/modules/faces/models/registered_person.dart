import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';

import 'package:flutter/widgets.dart' hide ValueGetter;

@immutable
class RegisteredPerson with CLLogger implements Comparable<RegisteredPerson> {
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
        name: map['name'] != null ? map['name'] as String : null,
        keyFaceId: map['keyFaceId'] != null ? map['keyFaceId'] as String : null,
        isHidden: (map['isHidden'] as int) != 0,
        faces: (map['faces'] as List<dynamic>).cast<String>(),
      );
    } catch (e) {
      /* print('Crashed here??'); */
      rethrow;
    }
  }

  factory RegisteredPerson.fromJson(String source) =>
      RegisteredPerson.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final String? name;
  final String? keyFaceId;
  final bool isHidden;
  final List<String> faces;

  @override
  String get logPrefix => 'RegisteredPerson';

  RegisteredPerson copyWith({
    int? id,
    ValueGetter<String?>? name,
    ValueGetter<String?>? keyFaceId,
    bool? isHidden,
    List<String>? faces,
  }) {
    return RegisteredPerson(
      id: id ?? this.id,
      name: name != null ? name.call() : this.name,
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

  @override
  int compareTo(RegisteredPerson other) {
    if (name != null && other.name != null) {
      return name!.compareTo(other.name!);
    }
    return id.compareTo(other.id);
  }

  bool get isNamed => name != null;
}
