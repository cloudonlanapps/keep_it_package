// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'test_modules.dart';

void main() async {
  late CLServer server;
  late Directory tempDir;
  late int collectionId;

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

      final result = await server.createEntity(
          isCollection: true, label: 'Test Collection');
      await result.when(
        validResponse: (result) async {
          expect(result.containsKey('id'), true,
              reason: "response doesn't contains id");
          collectionId = result['id'] as int;
        },
        errorResponse: (error, {st}) async {
          fail('$error');
        },
      );
    } catch (e) {
      fail('Failed: $e');
    }
  });
  tearDown(() async {
    // delete all the collection with it
    //FIXME: await server.deleteEntity(collectionId);
  });
  group('Test Media Interface', () {
    test('create and delete media', () async {
      final module = TestMediaModule(tempDir: tempDir, server: server);

      final entity0 =
          await module.createNewEntity(parentId: () => collectionId);
      entity0.remove('fileName');

      await module.delete(entity0['id'] as int,
          permanent: false,
          onSuccess: (response) async {
            print(response);
          },
          onError: (e) =>
              fail(e.toString())); // failOnerror is incorrect for this contexts

      await module.dispose();
    });
  });
}
