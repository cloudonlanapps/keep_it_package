import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:test/test.dart';

import 'test_modules.dart';
import 'text_ext_on_cl_server.dart';
import 'utils.dart';

void main() async {
  late CLServer server;
  late TestContext testContext;

  setUpAll(() async {
    server = await TextExtOnCLServer.establishConnection();
    testContext = TestContext(
        tempDir: 'image_test_dir_${randomString(5)}', server: server);
  });
  tearDownAll(() async {
    await testContext.dispose();
  });

  setUp(() async {});
  tearDown(() async {});
  group('Test Collection Interface', () {
    test(
        'R1 test getAll, and confirm all the items recently created present in it',
        () async {
      final itemsBefore = await (await server.getAll()).when(
          validResponse: (items) async => items,
          errorResponse: (e, {st}) async {
            fail('getAll Failed');
          });
      print('There are ${itemsBefore.length} items before this test');
      itemsBefore.forEach(print);

      final collectionLabel = randomString(8);
      final collection = await server.validCreate(testContext,
          isCollection: () => true, label: () => collectionLabel);

      final testMediaList = <CLEntity>[];

      for (var i = 0; i < 10; i++) {
        final fileName = testContext.createImage();
        final entity = await server.validCreate(
          testContext,
          fileName: fileName,
          parentId: () => collection.id!,
        );
        testMediaList.add(entity);
      }
      final items = await (await server.getAll()).when(
          validResponse: (items) async => items,
          errorResponse: (e, {st}) async {
            fail('getAll Failed');
          });
      print('There are ${items.length} items after this test');
      itemsBefore.forEach(print);
      for (final item in items) {
        print('checking item ${item.id}');
        expect(item.id, isNotNull); // assertion
        final expected =
            testMediaList.where((e) => e.id == item.id).firstOrNull;
        if (expected != null) {
          expect(item, expected, reason: "item retrived didn't match original");
        }
      }
    });
    test('R2 `getByID` returns valid entity if found', () async {
      final collectionLabels = List<String>.generate(1, (i) {
        return randomString(8);
      });
      final collections = <String, CLEntity>{};
      for (final label in collectionLabels) {
        collections[label] = await server.validCreate(testContext,
            isCollection: () => true, label: () => label);
      }

      for (final entry in collections.entries) {
        {
          final retrieved = await (await server.getById(entry.value.id!)).when(
              validResponse: (result) async {
            return result;
          }, errorResponse: (e, {st}) async {
            fail('failed to get collection with id ${entry.value.id}');
          });
          expect(retrieved, entry.value,
              reason: 'Retrived item must match the original item');
        }
      }
    });
    test('R3 `getByID` returns NotFound error when the item is not present',
        () async {
      for (final invalidId in [0, -1, 2000000000]) {
        await (await server.getById(invalidId)).when(
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
    });
    test(
        'R4 `get` with id / label returns valid entity if found for collection',
        () async {
      final collectionLabels = List<String>.generate(4, (i) {
        return randomString(8);
      });
      final collections = <String, CLEntity>{};
      for (final label in collectionLabels) {
        collections[label] = await server.validCreate(testContext,
            isCollection: () => true, label: () => label);
      }

      for (final entry in collections.entries) {
        {
          final retrieved =
              await (await server.get(queryString: 'id=${entry.value.id!}'))
                  .when(validResponse: (result) async {
            return result;
          }, errorResponse: (e, {st}) async {
            fail('failed to get collection with id ${entry.value.id} $e');
          });
          expect(retrieved, entry.value,
              reason: 'Retrived item must match the original item');
        }
        {
          final retrieved = await (await server.get(
                  queryString: 'label=${entry.value.label!}'))
              .when(validResponse: (result) async {
            return result;
          }, errorResponse: (e, {st}) async {
            fail('failed to get collection with id ${entry.value.id} $e');
          });
          expect(retrieved, entry.value,
              reason: 'Retrived item must match the original item');
        }
      }
    });
    test('R5 `get` with id / md5 returns valid entity if found for media',
        () async {
      final images = List<String>.generate(4, (i) {
        return testContext.createImage();
      });
      final media = <String, CLEntity>{};
      for (final fileName in images) {
        media[fileName] =
            await server.validCreate(testContext, fileName: fileName);
      }

      for (final entry in media.entries) {
        {
          final retrieved =
              await (await server.get(queryString: 'id=${entry.value.id!}'))
                  .when(validResponse: (result) async {
            return result;
          }, errorResponse: (e, {st}) async {
            fail('failed to get collection with id ${entry.value.id} $e');
          });
          expect(retrieved, entry.value,
              reason: 'Retrived item must match the original item');
        }
        {
          final retrieved =
              await (await server.get(queryString: 'md5=${entry.value.md5!}'))
                  .when(validResponse: (result) async {
            return result;
          }, errorResponse: (e, {st}) async {
            fail('failed to get collection with id ${entry.value.id} $e');
          });
          expect(retrieved, entry.value,
              reason: 'Retrived item must match the original item');
        }
      }
    });
  });
}
