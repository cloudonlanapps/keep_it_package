// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'test_modules.dart';
import 'utils.dart';

extension TestExtensionOnCLServer on CLServer {
  File generateFile(Directory tempDir) {
    final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
    generateRandomPatternImage(filename);
    final file = File(filename);
    if (!file.existsSync()) {
      fail('Unable to generate image file');
    }
    return file;
  }

  Future<void> createMediaTest(
      {required Directory tempDir,
      required Future<void> Function(Map<String, dynamic> map) onSuccess,
      required Future<void> Function(Map<String, dynamic> e) onError,
      String? Function()? label,
      int? Function()? parentId,
      String? Function()? filename}) async {
    final String? fileName0;

    if (filename == null) {
      fileName0 = generateFile(tempDir).path;
    } else {
      fileName0 = filename();
    }

    final result = await createEntity(
        isCollection: false,
        label: label != null ? label() : randomString(8),
        parentId: parentId != null ? parentId() : null,
        fileName: fileName0);
    await result.when(
        validResponse: (data) async {
          if (filename == null) {
            data['fileName'] = fileName0;
          }
          await onSuccess(data);
        },
        errorResponse: (e, {st}) => onError(e));
  }

  Future<void> updateMediaTest(int id,
      {required Directory tempDir,
      required Future<void> Function(Map<String, dynamic> map) onSuccess,
      required Future<void> Function(Map<String, dynamic> e) onError,
      String? Function()? label,
      int? Function()? parentId,
      String? Function()? filename}) async {
    final String? fileName0;

    if (filename == null) {
      fileName0 = generateFile(tempDir).path;
    } else {
      fileName0 = filename();
    }

    final result = await updateEntity(id,
        isCollection: false,
        label: label != null ? label() : randomString(8),
        parentId: parentId != null ? parentId() : null,
        fileName: fileName0);
    await result.when(
        validResponse: (data) async {
          if (filename == null) {
            data['fileName'] = fileName0;
          }
          await onSuccess(data);
        },
        errorResponse: (e, {st}) => onError(e));
  }

  Future<void> retriveById(
    int id, {
    required Future<void> Function(Map<String, dynamic>? map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
  }) async {
    final retrive = await getEntity('/entity/$id');
    await retrive.when(
      validResponse: (response) async {
        return onSuccess(response);
      },
      errorResponse: (e, {st}) async {
        return onError(e);
      },
    );
  }
}

void main() async {
  late CLServer server;
  late Directory tempDir;
  late int collectionId;
  late DeepCollectionEquality orderedDeepEquality;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('image_test_dir_');
    print('Created temporary directory: ${tempDir.path}');
  });
  tearDownAll(() async {
    print('Deleting temporary directory: ${tempDir.path}');
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    orderedDeepEquality = const DeepCollectionEquality();
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
    test('Can create a media and update it with same media', () async {
      final module = TestMediaModule(tempDir: tempDir, server: server);

      final entity0 =
          await module.createNewEntity(parentId: () => collectionId);
      expect(entity0['fileName'], isNotNull,
          reason: 'create must return fileName');

      await module.update(entity0['id'] as int,
          label: () => entity0['label'] as String,
          parentId: () => entity0['parentId'] as int,
          filename: () => entity0['fileName'] as String,
          onSuccess: (response) async {
            expect(orderedDeepEquality.equals(response, entity0), true,
                reason:
                    'update it with same media should return the same media');
          },
          onError: module.failOnerror);

      await module.dispose();
    });
    test('Can create a media and update it with different media', () async {
      final module = TestMediaModule(tempDir: tempDir, server: server);

      final entity0 =
          await module.createNewEntity(parentId: () => collectionId);
      expect(entity0['fileName'], isNotNull,
          reason: 'create must return fileName');

      await module.update(entity0['id'] as int,
          label: () => entity0['label'] as String,
          parentId: () => entity0['parentId'] as int,
          onSuccess: (response) async {
            expect(response['label'], entity0['label'] as String,
                reason: 'label should match');
            expect(response['parentId'], entity0['parentId'] as int,
                reason: 'parentId should match');
          },
          onError: module.failOnerror);

      await module.dispose();
    });
    test("Can create a media and send same parameters, but don't send file",
        () async {
      final module = TestMediaModule(tempDir: tempDir, server: server);

      final entity0 =
          await module.createNewEntity(parentId: () => collectionId);
      expect(entity0['fileName'], isNotNull,
          reason: 'create must return fileName');

      await module.update(entity0['id'] as int,
          label: () => entity0['label'] as String,
          parentId: () => entity0['parentId'] as int,
          filename: () => null,
          onSuccess: (response) async {
            expect(response['label'], entity0['label'] as String,
                reason: 'label should match');
            expect(response['parentId'], entity0['parentId'] as int,
                reason: 'parentId should match');
            final reference = Map<String, dynamic>.from(entity0)
              ..remove('fileName');
            expect(orderedDeepEquality.equals(response, reference), true,
                reason:
                    'update it with same media should return the same media');
          },
          onError: module.failOnerror);

      await module.dispose();
    });

    test('Can create a media and send label update', () async {
      final module = TestMediaModule(tempDir: tempDir, server: server);

      final entity0 = (await module.createNewEntity(
          parentId: () => collectionId))
        ..remove('fileName');
      final newLabel = randomString(12);
      await module.update(entity0['id'] as int,
          label: () => newLabel,
          parentId: () => entity0['parentId'] as int,
          filename: () => null,
          onSuccess: (response) async {
            final reference = Map<String, dynamic>.from(entity0)
              ..remove('updatedDate');
            response.remove('updatedDate');
            reference['label'] = newLabel;
            expect(orderedDeepEquality.equals(response, reference), true,
                reason:
                    'update it with same media should return the same media');
          },
          onError: module.failOnerror);

      await module.dispose();
    });
  });
}
