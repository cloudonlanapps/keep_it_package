import 'package:collection/collection.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:online_store/src/models/server_enitity_query.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';

/// 'parentId': ['__null__'] This will be interpreted as 'parentId': '__null__'
/// hence it will get valid reply. need modification in test to make sure
/// we test these combinations.

class TestFiltersLoopback {
  static Future<void> testLB1(TestContext testContext) async {
    final filters = [
      {'parentId': 10},
      {
        'parentId': [10, 11]
      },
      {'parentId': '__null__'},
      {'parentId': '__nonnull__'},
      {'id': 10},
      {
        'id': [10, 11]
      },
      {'id': '__null__'},
      {'id': '__nonnull__'}
    ];
    for (final testCombination in filters) {
      final queryString =
          ServerCLEntityQuery().getQueryString(map: testCombination);

      final reply = await (await testContext.server
              .filterLoopBack(queryString: queryString))
          .when(
              validResponse: (items) async => items,
              errorResponse: (e, {st}) async {
                fail('filterLoopBack Failed $e');
              });
      print(reply);
      final mapEquals = const DeepCollectionEquality().equals;
      expect(mapEquals(testCombination, reply), true,
          reason:
              'loopback must return same value\ninput:$testCombination\nloopback:$reply');
    }
  }

  static Future<void> testLB2(TestContext testContext) async {
    final filters = [
      {
        'parentId': ['abc']
      },
    ];
    for (final testCombination in filters) {
      final queryString =
          ServerCLEntityQuery().getQueryString(map: testCombination);

      final errorReply = await (await testContext.server
              .filterLoopBack(queryString: queryString))
          .when(validResponse: (items) async {
        fail('this test should have failed. $testCombination');
      }, errorResponse: (e, {st}) async {
        return e;
      });
      expect('parentId', isIn(errorReply.keys),
          reason: 'expect error with parentId');
    }
  }
}
