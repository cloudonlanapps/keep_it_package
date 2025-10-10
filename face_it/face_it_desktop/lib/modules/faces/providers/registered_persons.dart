import 'dart:async';
import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/registered_person.dart';
import '../models/registered_persons.dart';

final registeredPersonsProvider =
    AsyncNotifierProvider<RegisteredPersonsNotifier, RegisteredPersons>(
      RegisteredPersonsNotifier.new,
    );

class RegisteredPersonsNotifier extends AsyncNotifier<RegisteredPersons>
    with CLLogger {
  CLServer? server;
  @override
  FutureOr<RegisteredPersons> build() async {
    server = await ref.watch(activeAIServerProvider.future);

    if (server == null) {
      return const RegisteredPersons([]);
    } else {
      final result = await server!.get('/store/persons');
      final persons = await result.when(
        validResponse: (result) async {
          try {
            final persons = RegisteredPersons.fromMap({
              'persons': jsonDecode(result as String),
            });

            return persons;
          } catch (e) {
            rethrow;
          }
        },
        errorResponse: (error, {st}) async {
          throw Exception(error);
        },
      );
      return persons;
    }
  }

  Future<RegisteredPerson?> getRegisteredPerson(int id) async {
    final currentItems = state.value;
    final localPerson = currentItems?.persons
        .where((item) => item.id == id)
        .firstOrNull;

    if (localPerson != null) {
      return localPerson; // Present locally
    }

    if (server == null) return null;
    final personReply = await server!.get('/store/person/$id');
    final person = await personReply.when(
      validResponse: (personJson) async {
        return RegisteredPerson.fromJson(personJson as String);
      },
      errorResponse: (e, {st}) async {
        log('person with $id not found');
        return null;
      },
    );
    if (person != null) {
      final currentItems = state.value!;
      final updatedList = [
        ...currentItems.persons.where((item) => item.id != id),
        person,
      ];
      state = AsyncData(currentItems.copyWith(persons: updatedList));
    }
    return person;
  }

  void setActive(RegisteredPerson person) {
    if (state.hasValue) {
      state = AsyncData(state.asData!.value.setActive(person.id));
    }
  }

  @override
  String get logPrefix => 'RegisteredPersonsNotifier';
}
