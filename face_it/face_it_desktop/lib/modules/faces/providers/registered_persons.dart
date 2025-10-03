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
    print('server is $server');
    if (server == null) {
      return const RegisteredPersons([]);
    } else {
      final result = await server.get('/store/persons');
      final persons = await result.when(
        validResponse: (result) async {
          print('valid response received...');
          try {
            final persons = RegisteredPersons.fromMap({
              'persons': jsonDecode(result as String),
            });

            print('receeived ,,,, persons $persons');
            return persons;
          } catch (e) {
            print('error $e');
            rethrow;
          }
        },
        errorResponse: (error, {st}) async {
          print('error !!! $error');
          throw Exception(error);
        },
      );
      return persons;
    }
  }
}
