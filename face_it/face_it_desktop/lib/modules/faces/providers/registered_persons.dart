import 'dart:async';
import 'dart:convert';

import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/registered_persons.dart';

final registeredPersonsProvider =
    AsyncNotifierProvider<RegisteredPersonsNotifier, RegisteredPersons>(
      RegisteredPersonsNotifier.new,
    );

class RegisteredPersonsNotifier extends AsyncNotifier<RegisteredPersons> {
  @override
  FutureOr<RegisteredPersons> build() async {
    final server = await ref.watch(activeAIServerProvider.future);

    if (server == null) {
      return const RegisteredPersons([]);
    } else {
      final result = await server.get('/store/persons');
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
}
