import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'utils.dart';

abstract class CLOnlineServerTestModule {
  CLOnlineServerTestModule(
      {required this.tempDir,
      required this.server,
      this.orderedDeepEquality = const DeepCollectionEquality()});

  final Directory tempDir;
  final CLServer server;
  final List<String> fileArtifacts = [];
  final DeepCollectionEquality orderedDeepEquality;

  Future<void> dispose() async {
    for (final file in fileArtifacts) {
      await File(file).deleteIfExists();
    }
  }

  File generateFile(Directory tempDir) {
    final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
    generateRandomPatternImage(filename);
    final file = File(filename);
    if (!file.existsSync()) {
      fail('Unable to generate image file');
    }
    return file;
  }

  Future<void> create({
    required Future<void> Function(Map<String, dynamic> map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
  });
  Future<void> update(
    int id, {
    required Future<void> Function(Map<String, dynamic> map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
  });
  Future<void> retrieve(
    int id, {
    required Future<void> Function(Map<String, dynamic>? map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
  });

  Future<void> delete(int id,
      {required Future<void> Function(Map<String, dynamic> map) onSuccess,
      required Future<void> Function(Map<String, dynamic> e) onError,
      required bool permanent});
}

@immutable
class TestMediaModule extends CLOnlineServerTestModule {
  TestMediaModule({required super.tempDir, required super.server});

  @override
  Future<void> create({
    required Future<void> Function(Map<String, dynamic> map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
    ValueGetter<String?>? label,
    ValueGetter<int?>? parentId,
    ValueGetter<String?>? filename,
  }) async {
    final String? fileName0;

    if (filename == null) {
      fileName0 = generateFile(tempDir).path;
      fileArtifacts.add(fileName0); // Add to artifacts to dispose later
    } else {
      fileName0 = filename();
    }

    final result = await server.createEntity(
        isCollection: false,
        label: label != null ? label() : randomString(8),
        parentId: parentId?.call(),
        fileName: fileName0);
    await result.when(
        validResponse: (response) async {
          expect(response.containsKey('id'), true,
              reason: 'Unable to create a media');
          if (fileName0 != null) {
            expect(response['fileSize'], File(fileName0).lengthSync(),
                reason: 'Received unexpected file length when create');
          }
          final id = response['id'] as int;

          await retrieve(id, onError: failOnerror,
              onSuccess: (retrieved) async {
            expect(orderedDeepEquality.equals(retrieved, response), true,
                reason: 'mismatch between created value and retrived value');
          });
          if (fileName0 != null) {
            response['fileName'] = fileName0;
          }
          return onSuccess(response);
        },
        errorResponse: (e, {st}) => onError(e));
    return;
  }

  @override
  Future<void> retrieve(
    int id, {
    required Future<void> Function(Map<String, dynamic>? map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
  }) async {
    final retrive = await server.getEntity('/entity/$id');
    await retrive.when(
      validResponse: (response) async {
        return onSuccess(response);
      },
      errorResponse: (e, {st}) async {
        return onError(e);
      },
    );
  }

  @override
  Future<void> update(
    int id, {
    required Future<void> Function(Map<String, dynamic> map) onSuccess,
    required Future<void> Function(Map<String, dynamic> e) onError,
    ValueGetter<String?>? label,
    ValueGetter<int?>? parentId,
    ValueGetter<String?>? filename,
  }) async {
    final String? fileName0;

    if (filename == null) {
      fileName0 = generateFile(tempDir).path;
      fileArtifacts.add(fileName0); // Add to artifacts to dispose later
    } else {
      fileName0 = filename();
    }

    final result = await server.updateEntity(id,
        isCollection: false,
        label: label != null ? label() : randomString(8),
        parentId: parentId?.call(),
        fileName: fileName0);
    await result.when(
        validResponse: (response) async {
          expect(response.containsKey('id'), true,
              reason: 'Unable to create a media');
          if (fileName0 != null) {
            expect(response['fileSize'], File(fileName0).lengthSync(),
                reason: 'Received unexpected file length when update');
          }

          final id = response['id'] as int;

          await retrieve(id, onError: failOnerror,
              onSuccess: (retrieved) async {
            expect(orderedDeepEquality.equals(retrieved, response), true,
                reason: 'mismatch between updated value and retrived value');
          });
          if (fileName0 != null) {
            response['fileName'] = fileName0;
          }
          await onSuccess(response);
        },
        errorResponse: (e, {st}) => onError(e));
  }

  @override
  Future<void> delete(int id,
      {required Future<void> Function(Map<String, dynamic> map) onSuccess,
      required Future<void> Function(Map<String, dynamic> e) onError,
      required bool permanent}) async {
    final softDeleteResult = await server.softDeleteEntity(id);
    await softDeleteResult.when(
        validResponse: (response) async {
          expect(response['isDeleted'], '1',
              reason: 'isDeleted != 1, delete failed');
        },
        errorResponse: (e, {st}) => fail('soft delete failed $e'));

    await retrieve(id,
        onSuccess: (response) async {
          expect(response, isNotNull,
              reason: 'failed to retrive after soft delete');
          expect(response!['isDeleted'], '1',
              reason: 'isDeleted != 1, delete failed');
        },
        onError: (e, {st}) => fail('retrieve failed after soft delete'));

    /* final result = await server.deleteEntity(id);
    await result.when(
        validResponse: onSuccess, errorResponse: (e, {st}) => onError(e)); */
  }

  Future<void> failOnerror(Map<String, dynamic> e) async {
    fail('failed to retrive created Media Failed. $e');
  }

  Future<Map<String, dynamic>> createNewEntity(
      {int? Function()? parentId}) async {
    late final Map<String, dynamic>? entry0;
    await create(
        parentId: parentId,
        onError: failOnerror,
        onSuccess: (response) async {
          entry0 = response;
        });

    return entry0!;
  }
}
