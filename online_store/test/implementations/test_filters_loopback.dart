import 'package:collection/collection.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:online_store/src/models/server_enitity_query.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';
import 'filter_invalid_test_cases.dart';
import 'filters_valid_combinations.dart';

/// 'parentId': ['__null__'] This will be interpreted as 'parentId': '__null__'
/// hence it will get valid reply. need modification in test to make sure
/// we test these combinations.

class TestFiltersLoopback {
  static Future<void> testLB1(TestContext testContext) async {
    for (final testCombination in filterValidTestCases) {
      final queryString =
          ServerCLEntityQuery().getQueryString(map: testCombination);

      final reply = await (await testContext.server
              .filterLoopBack(queryString: queryString))
          .when(
              validResponse: (items) async =>
                  items['loopback'] as Map<String, dynamic>,
              errorResponse: (e, {st}) async {
                fail('filterLoopBack Failed $e');
              });
      print(reply);
      final mapEquals = const DeepCollectionEquality().equals;
      expect(mapEquals(testCombination, reply), true,
          reason: 'loopback must return same value\n'
              'input:$testCombination\n'
              'loopback:$reply');
    }
  }

  static Future<void> testLB2(TestContext testContext) async {
    for (final testCombination in filterInvalidTestCases) {
      final queryString =
          ServerCLEntityQuery().getQueryString(map: testCombination);

      final errorReply = await (await testContext.server
              .filterLoopBack(queryString: queryString))
          .when(validResponse: (items) async {
        fail(
            'this test should have failed. $testCombination\n${items['loopback']}');
      }, errorResponse: (e, {st}) async {
        return e;
      });

      expect(errorReply['type'], 'ValidationError',
          reason: 'invalid cases should return ValidationError');
    }
  }
}
