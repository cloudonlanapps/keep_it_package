import 'dart:convert';

import 'package:cl_servers/cl_servers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'face_descriptor.dart';
import 'face_state_manager.dart';
import 'guessed_face.dart';
import '../../faces/models/registered_person.dart';

///     Face Transition
///
///                          Unchecked
///                              │ vectorSearch()
///                  ┌───────────┴───────────────────────────────┐
///               notFound                                     found
///     ┌─────────────┼──────────────┐                 ┌─────────┴───┐
///     │ notAface()  │ notKnown()   │ register()      │ confirm()   │ reject()
///  notAface      notKnown       confirm           confirm       notFound
///
///

enum FaceStatus {
  notChecked,

  found,
  foundConfirmed,

  notFound,
  notFoundNotAFace,
  notFoundUnknown;

  String get label => switch (this) {
    notChecked => 'New Face',
    found => 'Found',
    foundConfirmed => 'Confirmed',
    notFound => 'Not Found',
    notFoundNotAFace => 'Not A Face',
    notFoundUnknown => 'Unknown',
  };

  bool get canConfirm => switch (this) {
    notChecked => true,
    notFound => true,
    notFoundUnknown => true,
    found => true,
    foundConfirmed => false, // Already found, must remove confirmation before
    notFoundNotAFace => false, // clear the flag to proceed
  };

  bool get canRecognize => switch (this) {
    notChecked => true,
    notFound => true,
    notFoundUnknown => true,
    FaceStatus.found =>
      false, //'Reject all earlier guesses before updating with search results',
    FaceStatus.foundConfirmed => false, //Already confirmed
    FaceStatus.notFoundNotAFace =>
      false, //This is not a face, unflag to proceed
  };
}

@immutable
class DetectedFace implements FaceStateManager {
  const DetectedFace({
    required this.descriptor,
    required this.guesses,
    required this.status,
    required this.person,
  });
  factory DetectedFace.notChecked({required FaceDescriptor descriptor}) {
    return DetectedFace(
      descriptor: descriptor,
      status: FaceStatus.notChecked,
      guesses: null,
      person: null,
    );
  }
  factory DetectedFace.found({
    required FaceDescriptor descriptor,
    required List<GuessedPerson> guesses,
  }) {
    return DetectedFace(
      descriptor: descriptor,
      status: FaceStatus.found,
      guesses: guesses,
      person: null,
    );
  }
  factory DetectedFace.confirm({
    required FaceDescriptor descriptor,
    required RegisteredPerson person,
  }) {
    return DetectedFace(
      descriptor: descriptor,
      status: FaceStatus.foundConfirmed,
      guesses: null,
      person: person,
    );
  }

  factory DetectedFace.notFound({required FaceDescriptor descriptor}) {
    return DetectedFace(
      descriptor: descriptor,
      status: FaceStatus.notFound,
      guesses: null,
      person: null,
    );
  }
  factory DetectedFace.notAFace({required FaceDescriptor descriptor}) {
    return DetectedFace(
      descriptor: descriptor,
      status: FaceStatus.notFoundNotAFace,
      guesses: null,
      person: null,
    );
  }
  factory DetectedFace.unknown({required FaceDescriptor descriptor}) {
    return DetectedFace(
      descriptor: descriptor,
      status: FaceStatus.notFoundUnknown,
      guesses: null,
      person: null,
    );
  }

  final FaceDescriptor descriptor;
  final FaceStatus status;
  final RegisteredPerson? person;
  final List<GuessedPerson>? guesses;

  DetectedFace copyWith({
    FaceDescriptor? descriptor,
    FaceStatus? status,
    ValueGetter<RegisteredPerson?>? person,
    ValueGetter<List<GuessedPerson>?>? guesses,
  }) {
    return DetectedFace(
      descriptor: descriptor ?? this.descriptor,
      status: status ?? this.status,
      person: person != null ? person.call() : this.person,
      guesses: guesses != null ? guesses.call() : this.guesses,
    );
  }

  @override
  String toString() {
    return 'DetectedFace(descriptor: $descriptor, status: $status, person: $person, guesses: $guesses)';
  }

  @override
  bool operator ==(covariant DetectedFace other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.descriptor == descriptor &&
        other.status == status &&
        other.person == person &&
        listEquals(other.guesses, guesses);
  }

  @override
  int get hashCode {
    return descriptor.hashCode ^
        status.hashCode ^
        person.hashCode ^
        guesses.hashCode;
  }

  String formatName(String name) {
    return name
        .split(RegExp(r'\s+')) // split on spaces/tabs
        .map((word) {
          if (word.isEmpty) return word;
          final first = word.characters.first.toUpperCase();
          final rest = word.characters.skip(1).toString();
          return '$first$rest';
        })
        .join(' ');
  }

  String get label => formatName(switch (status) {
    FaceStatus.notChecked => 'Unchecked',
    FaceStatus.found => guesses![0].person.name,
    FaceStatus.foundConfirmed => person!.name,
    FaceStatus.notFound => 'New Face',
    FaceStatus.notFoundNotAFace => 'Not A Face',
    FaceStatus.notFoundUnknown => 'Unknown',
  });

  DetectedFace confirm(RegisteredPerson person) {
    if (status.canConfirm) {
      return DetectedFace.confirm(descriptor: descriptor, person: person);
    }
    return this;
  }

  DetectedFace vectorSearchResults(List<GuessedPerson>? guesses) {
    if (status.canRecognize) {
      final DetectedFace face;
      if (guesses != null && guesses.isNotEmpty) {
        face = DetectedFace.found(descriptor: descriptor, guesses: guesses);
      } else {
        face = DetectedFace.notFound(descriptor: descriptor);
      }
      return face;
    }
    return this;
  }

  @override
  DetectedFace confirmTaggedFace(RegisteredPerson person) =>
      DetectedFace.confirm(descriptor: descriptor, person: person);

  @override
  DetectedFace isAFace() => DetectedFace.notChecked(descriptor: descriptor);

  @override
  DetectedFace markAsUnknown() => DetectedFace.unknown(descriptor: descriptor);

  @override
  DetectedFace markNotAFace() => DetectedFace.notAFace(descriptor: descriptor);

  @override
  DetectedFace rejectTaggedPerson(RegisteredPerson person) {
    if (guesses == null) return this;
    // Remove the person
    final updated = guesses!.where((e) => e.person.id != person.id).toList();
    if (updated.isEmpty) {
      return DetectedFace.notFound(descriptor: descriptor);
    } else {
      return DetectedFace.found(descriptor: descriptor, guesses: updated);
    }
  }

  @override
  DetectedFace removeConfirmation() =>
      DetectedFace.notChecked(descriptor: descriptor);

  @override
  Future<DetectedFace> register(CLServer server, String name) async {
    final reply = await server.post(
      '/store/register_face/of/$name',
      filesFields: {
        'face': [descriptor.imageCache],
        'vector': [descriptor.vectorCache],
      },
    );
    return reply.when(
      validResponse: (result) async {
        return DetectedFace.confirm(
          descriptor: descriptor,
          person: RegisteredPerson.fromJson(result as String),
        );
      },
      errorResponse: (e, {st}) async {
        return this;
      },
    );
  }

  @override
  Future<DetectedFace> searchDB(CLServer server) async {
    final reply = await server.post(
      '/store/search',
      filesFields: {
        'vector': [descriptor.vectorCache],
      },
    );
    return reply.when(
      validResponse: (result) async {
        final decoded = jsonDecode(result as String);

        if (decoded is! List) {
          throw ArgumentError('Expected a JSON list');
        }

        final map = {
          for (final item in decoded)
            if (item is Map &&
                item.containsKey('name') &&
                item.containsKey('confidence'))
              item['name'].toString(): (item['confidence'] as num).toDouble(),
        };

        final guesses = <GuessedPerson>[];
        for (final name in map.keys) {
          if (map[name]! > 0.5) {
            final personReply = await server.get('/store/person/$name');
            final person = await personReply.when(
              validResponse: (personJson) async {
                return RegisteredPerson.fromJson(personJson as String);
              },
              errorResponse: (e, {st}) async {
                return null;
              },
            );
            if (person != null) {
              guesses.add(
                GuessedPerson(person: person, confidence: map[name]!),
              );
            }
          }
        }

        if (guesses.isNotEmpty) {
          return DetectedFace.found(descriptor: descriptor, guesses: guesses);
        } else {
          return DetectedFace.notFound(descriptor: descriptor);
        }
      },
      errorResponse: (e, {st}) async {
        return this;
      },
    );
  }
}
