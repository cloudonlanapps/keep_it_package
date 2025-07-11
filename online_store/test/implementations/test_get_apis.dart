import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:test/test.dart';
import '../framework/framework.dart';

class TestGetAPIs {
  static Future<void> testR1(TestContext testContext) async {
    final collectionLabel = randomString(8);
    final collection = await testContext.server.validCreate(testContext,
        isCollection: () => true, label: () => collectionLabel);

    final testMediaList = <CLEntity>[];

    for (var i = 0; i < 10; i++) {
      final fileName = testContext.createImage();
      final entity = await testContext.server.validCreate(
        testContext,
        fileName: fileName,
        parentId: () => collection.id,
      );
      testMediaList.add(entity);
    }
    final items = await (await testContext.server.getAll()).when(
        validResponse: (items) async => items,
        errorResponse: (e, {st}) async {
          fail('getAll Failed');
        });

    for (final item in items) {
      expect(item.id, isNotNull); // assertion
      final expected = testMediaList.where((e) => e.id == item.id).firstOrNull;
      if (expected != null) {
        expect(item, expected, reason: "item retrived didn't match original");
      }
    }
  }

  static Future<void> testR2(TestContext testContext) async {
    final collectionLabels = List<String>.generate(1, (i) {
      return randomString(8);
    });
    final collections = <String, CLEntity>{};
    for (final label in collectionLabels) {
      collections[label] = await testContext.server.validCreate(testContext,
          isCollection: () => true, label: () => label);
    }

    for (final entry in collections.entries) {
      {
        final retrieved =
            await (await testContext.server.getById(entry.value.id!)).when(
                validResponse: (result) async {
          return result;
        }, errorResponse: (e, {st}) async {
          fail('failed to get collection with id ${entry.value.id}');
        });
        expect(retrieved, entry.value,
            reason: 'Retrived item must match the original item');
      }
    }
  }

  static Future<void> testR3(TestContext testContext) async {
    for (final invalidId in [0, -1, 2000000000]) {
      await (await testContext.server.getById(invalidId)).when(
          validResponse: (result) async {
        fail('Expected not to succeed');
      }, errorResponse: (e, {st}) async {
        {
          expect(
            e['type'],
            anyOf('MissingPageError', 'MissingMediaError'),
            reason: 'must get MissingMediaError error',
          );
        }
      });
    }
  }

  static Future<void> testR4(TestContext testContext) async {
    final collectionLabels = List<String>.generate(4, (i) {
      return randomString(8);
    });
    final collections = <String, CLEntity>{};
    for (final label in collectionLabels) {
      collections[label] = await testContext.server.validCreate(testContext,
          isCollection: () => true, label: () => label);
    }

    for (final entry in collections.entries) {
      {
        final retrieved =
            await (await testContext.server.get(label: entry.value.label)).when(
                validResponse: (result) async {
          return result;
        }, errorResponse: (e, {st}) async {
          fail('failed to get collection with id ${entry.value.id} $e');
        });
        expect(retrieved, entry.value,
            reason: 'Retrived item must match the original item');
      }
    }
  }

  static Future<void> testR5(TestContext testContext) async {
    final images = List<String>.generate(4, (i) {
      return testContext.createImage();
    });
    final media = <String, CLEntity>{};
    for (final fileName in images) {
      media[fileName] =
          await testContext.server.validCreate(testContext, fileName: fileName);
    }

    for (final entry in media.entries) {
      {
        final retrieved =
            await (await testContext.server.get(md5: entry.value.md5)).when(
                validResponse: (result) async {
          return result;
        }, errorResponse: (e, {st}) async {
          fail('failed to get media with id ${entry.value.id} $e');
        });
        expect(retrieved, entry.value,
            reason: 'Retrived item must match the original item');
      }
    }
  }
}
