// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'utils.dart';

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
        errorResponse: (error, {st}) {
          fail('$error');
        },
      );
    } catch (e) {
      fail('Failed: $e');
    }
  });
  tearDown(() async {
    // delete all the collection with it
    await server.deleteEntity({'id': collectionId});
  });
  group('Test Media Interface', () {
    test('Can create a media', () async {
      final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
      generateRandomPatternImage(filename);
      if (File(filename).existsSync()) {
        final result = await server.createEntity(
            isCollection: false,
            label: randomString(8),
            parentId: collectionId,
            fileName: filename);
        await result.when(
            validResponse: (data) async => expect(data.containsKey('id'), true,
                reason: 'Unable to create a media'),
            errorResponse: (e, {st}) =>
                fail('failed to create media, Error: $e'));
      } else {
        fail('Unable to generate image file');
      }
    });

    test("Can't create a media without a file", () async {
      final result = await server.createEntity(
        isCollection: false,
        label: randomString(8),
        parentId: collectionId,
      );
      await result.when(
          validResponse: (data) =>
              fail("valid Media can't be posted without a file."),
          errorResponse: (e, {st}) async {
            if (e.containsKey('error') &&
                (e['error'] as String).contains('Post media with a file')) {
            } else {
              fail('unexpected error $e');
            }
          });
    });
  });
}
