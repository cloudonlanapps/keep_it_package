import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:online_store/src/models/server_enitity_query.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';

class TestFilters {
  static Future<void> testF1(TestContext testContext) async {
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

    final queryString =
        ServerCLEntityQuery().getQueryString(map: {'parentId': collection.id});

    final items =
        await (await testContext.server.getAll(queryString: queryString)).when(
            validResponse: (items) async => items,
            errorResponse: (e, {st}) async {
              fail('getAll Failed');
            });
    expect(items.length, 10,
        reason:
            'Must return exact same number of items uploaded into the specific collection');
    for (final item in items) {
      expect(item.id, isNotNull); // assertion
      final expected = testMediaList.where((e) => e.id == item.id).firstOrNull;
      if (expected != null) {
        expect(item, expected, reason: "item retrived didn't match original");
      }
    }
  }

  static Future<void> testF2(TestContext testContext) async {
    final queryString =
        ServerCLEntityQuery().getQueryString(map: {'parentId': null});
    final itemsFilterred =
        await (await testContext.server.getAll(queryString: queryString)).when(
            validResponse: (items) async => items,
            errorResponse: (e, {st}) async {
              fail('getAll with Filter Failed  $e');
            });
    final itemsAll = await (await testContext.server.getAll()).when(
        validResponse: (items) async => items,
        errorResponse: (e, {st}) async {
          fail('getAll Failed $e');
        });
    final itemsWithoutParent = itemsAll.where((e) => e.parentId == null);
    final itemsRetrieved = itemsFilterred
      ..sort((e1, e2) => e1.id!.compareTo(e2.id!));
    final mapEquals = const DeepCollectionEquality().equals;

    expect(mapEquals(itemsWithoutParent, itemsRetrieved), true,
        reason: 'Retried items should include all items without parent');
  }
}
