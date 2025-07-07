// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

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
    orderedDeepEquality = const DeepCollectionEquality();
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
    await server.deleteEntity({'id': collectionId});
  });
  group('Test Media Interface', () {
    test('Can create a media and update it with same media', () async {
      final filesCreated = <String>[];
      await server.createMediaTest(
        tempDir: tempDir,
        parentId: () => collectionId,
        onError: (e) {
          fail('createMedia Failed. $e');
        },
        onSuccess: (entry0) async {
          final filename = entry0['fileName'] as String;
          entry0.remove('fileName');
          filesCreated.add(filename);
          expect(entry0.containsKey('id'), true,
              reason: 'Unable to create a media');
          expect(entry0['fileSize'], File(filename).lengthSync(),
              reason: 'Received unexpected file length');
          await server.retriveById(
            entry0['id'] as int,
            onSuccess: (map) async {
              expect(orderedDeepEquality.equals(entry0, map), true,
                  reason: 'mismatch between created value and retrived value');
            },
            onError: (e) {
              fail('failed to retrive created Media Failed. $e');
            },
          );
          await server.updateMediaTest(
            entry0['id'] as int,
            tempDir: tempDir,
            label: () => entry0['label'] as String,
            parentId: () => entry0['parentId'] as int,
            filename: () => filename,
            onError: (e) {
              fail('update Media Failed. $e');
            },
            onSuccess: (entry1) async {
              expect(orderedDeepEquality.equals(entry1, entry0), true,
                  reason:
                      'update it with same media should return the same media');
              await server.retriveById(
                entry1['id'] as int,
                onSuccess: (map) async {
                  expect(orderedDeepEquality.equals(entry1, map), true,
                      reason:
                          'mismatch between created value and retrived value');
                },
                onError: (e) {
                  fail('failed to retrive created Media Failed. $e');
                },
              );
            },
          );
          await File(filename).deleteIfExists();
        },
      );
    });
    test('Can create a media and update it with different media', () async {
      final filesCreated = <String>[];
      await server.createMediaTest(
        tempDir: tempDir,
        parentId: () => collectionId,
        onError: (e) {
          fail('createMedia Failed. $e');
        },
        onSuccess: (entry0) async {
          final filename = entry0['fileName'] as String;
          entry0.remove('fileName');
          await server.retriveById(
            entry0['id'] as int,
            onSuccess: (map) async {
              expect(orderedDeepEquality.equals(entry0, map), true,
                  reason: 'mismatch between created value and retrived value');
            },
            onError: (e) {
              fail('failed to retrive created Media Failed. $e');
            },
          );

          filesCreated.add(filename);
          expect(entry0.containsKey('id'), true,
              reason: 'Unable to create a media');
          expect(entry0['fileSize'], File(filename).lengthSync(),
              reason: 'Received unexpected file length');

          await server.updateMediaTest(
            entry0['id'] as int,
            tempDir: tempDir,
            label: () => entry0['label'] as String,
            parentId: () => entry0['parentId'] as int,
            onError: (e) {
              fail('update Media Failed. $e');
            },
            onSuccess: (entry1) async {
              final filename = entry1['fileName'] as String;
              entry1.remove('fileName');
              filesCreated.add(filename);
              await server.retriveById(
                entry1['id'] as int,
                onSuccess: (map) async {
                  expect(orderedDeepEquality.equals(entry1, map), true,
                      reason:
                          'mismatch between created value and retrived value');
                },
                onError: (e) {
                  fail('failed to retrive created Media Failed. $e');
                },
              );

              expect(entry1['fileSize'], File(filename).lengthSync());
              expect(entry1['md5'] != entry0['md5'], true,
                  reason: 'The md5 value must be diffent');
            },
          );
        },
      );
      for (final file in filesCreated) {
        await File(file).deleteIfExists();
      }
    });
    test('Can create a media and update it with different media', () async {
      final filesCreated = <String>[];
      await server.createMediaTest(
        tempDir: tempDir,
        parentId: () => collectionId,
        onError: (e) {
          fail('createMedia Failed. $e');
        },
        onSuccess: (entry0) async {
          final filename = entry0['fileName'] as String;
          entry0.remove('fileName');
          filesCreated.add(filename);
          expect(entry0.containsKey('id'), true,
              reason: 'Unable to create a media');
          expect(entry0['fileSize'], File(filename).lengthSync(),
              reason: 'Received unexpected file length');
          final label = randomString(10);
          await server.updateMediaTest(
            entry0['id'] as int,
            tempDir: tempDir,
            filename: () => filename,
            label: () => label,
            parentId: () => entry0['parentId'] as int,
            onError: (e) {
              fail('update Media Failed. $e');
            },
            onSuccess: (entry1) async {
              expect(entry1['fileSize'], File(filename).lengthSync());
              expect(entry1['md5'] == entry0['md5'], true,
                  reason: 'The md5 value must be diffent');
              expect(entry1['label'], label, reason: "label does't match");
            },
          );
        },
      );
      for (final file in filesCreated) {
        await File(file).deleteIfExists();
      }
    });
  });
}
