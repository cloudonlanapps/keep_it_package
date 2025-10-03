import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:face_it_desktop/modules/faces/models/registered_person.dart';
import 'package:flutter/widgets.dart';

@immutable
class RegisteredPersons {
  const RegisteredPersons(this.persons);

  factory RegisteredPersons.fromMap(Map<String, dynamic> map) {
    return RegisteredPersons(
      List<RegisteredPerson>.from(
        (map['persons'] as List<dynamic>).map<RegisteredPerson>(
          (x) => RegisteredPerson.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  factory RegisteredPersons.fromJson(String source) =>
      RegisteredPersons.fromMap(json.decode(source) as Map<String, dynamic>);
  final List<RegisteredPerson> persons;

  RegisteredPersons copyWith({List<RegisteredPerson>? persons}) {
    return RegisteredPersons(persons ?? this.persons);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'persons': persons.map((x) => x.toMap()).toList()};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'RegisteredPersons(persons: $persons)';

  @override
  bool operator ==(covariant RegisteredPersons other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.persons, persons);
  }

  @override
  int get hashCode => persons.hashCode;
}
