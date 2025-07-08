// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:online_store/src/implementations/cl_server.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'utils.dart';

/// Add Tests for
/// Creating a collection with file
/// Creating a collection with parentId

void main() async {
  late CLServer server;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('image_test_dir_');
    print('Created temporary directory: ${tempDir.path}');
  });
  tearDownAll(() async {
    print('Deleting temporary directory: ${tempDir.path}');
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    try {
      final url = StoreURL(Uri.parse('http://127.0.0.1:5001'),
          identity: null, label: null);

      server = await CLServer(storeURL: url).withId();
      if (!server.hasID) {
        fail('Connection Failed, could not get the server Id');
      }
    } catch (e) {
      fail('Failed: $e');
    }
  });
  group('Test Collection Interface', () {
    test('C1 can create a collection with label', () async {
      final label = randomString(8, prefix: 'test_');
      final reply =
          await server.upsert(isCollection: () => true, label: () => label);
      final reference = await reply.when(
        validResponse: (result) async {
          expect(result.id, isNotNull, reason: "response doesn't contains id");
          expect(result.label, label,
              reason: "response doesn't contains label");

          expect(result.description, isNull,
              reason: 'description is not matching');
          return result;
        },
        errorResponse: (error, {st}) async {
          fail('$error');
        },
      );
      await server.toBin(reference.id!);
    });
  });
}
