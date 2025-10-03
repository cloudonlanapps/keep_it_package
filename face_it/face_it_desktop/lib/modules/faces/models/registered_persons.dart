import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:face_it_desktop/modules/faces/models/registered_person.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class RegisteredPersons {
  const RegisteredPersons(this.persons, {this.activePersonId});

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
  final int? activePersonId;

  RegisteredPersons copyWith({
    List<RegisteredPerson>? persons,
    ValueGetter<int?>? activeMediaId,
  }) {
    return RegisteredPersons(
      persons ?? this.persons,
      activePersonId: activeMediaId != null
          ? activeMediaId.call()
          : activePersonId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'persons': persons.map((x) => x.toMap()).toList()};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'RegisteredPersons(persons: $persons, activeMediaId: $activePersonId)';

  @override
  bool operator ==(covariant RegisteredPersons other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.persons, persons) &&
        other.activePersonId == activePersonId;
  }

  @override
  int get hashCode => persons.hashCode ^ activePersonId.hashCode;

  RegisteredPersons setActive(int? value) {
    if (value == null) {
      return copyWith(activeMediaId: () => null);
    }
    final activeFileUpdated = persons
        .where((e) => e.id == value)
        .firstOrNull
        ?.id;
    return copyWith(activeMediaId: () => activeFileUpdated);
  }

  RegisteredPerson? get activePerson =>
      persons.where((e) => e.id == activePersonId).firstOrNull;
}
