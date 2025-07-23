// ignore_for_file: avoid_print, print required for testing

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:online_store/src/models/server_enitity_query.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';
import 'filter_invalid_test_cases.dart';
import 'filters_valid_combinations.dart';

/// The API accepts slightly modified formats also as input.
/// the typical cases are the int and double values can also be
/// provided as convertible string,
/// a single value can be sent as a string. 'parentId': ['__null__']
/// These cases are treated as valid, but the response will be
/// valid (normalized) and may not match the input. Hence, we should
/// normalize the input and then compare the map when validating.
/// Note response shouldn't be normalized. Also input should be normaized
/// when passing to the API. normalization is only when we compare.

typedef NumParser<T extends num> = T? Function(String source);

extension Normalize on Map<String, dynamic> {
  static dynamic normalizeValue<T extends num>(
      dynamic val, NumParser<T> parser) {
    return switch (val) {
      T() => val, // Already the target numeric type
      final bool valBool => valBool ? 1 : 0,
      final DateTime valDateTime => valDateTime.utcTimeStamp,
      final String valString =>
        parser(valString) ?? valString, // Try parsing, else keep as string
      final List<dynamic> valList =>
        valList.map((e) => normalizeValue<T>(e, parser)).toList(),
      final Map<String, dynamic> valMap => valMap
          .map((key, value) => MapEntry(key, normalizeValue<T>(value, parser))),
      _ => val
    };
  }

  Map<String, dynamic> get normalized {
    final result = <String, dynamic>{};
    for (final entry in entries) {
      final normalizedValue = switch (entry.key) {
        (String _)
            when [
              'isCollection',
              'isDeleted',
              'id',
              'parentId',
              'ImageHeight',
              'ImageWidth',
              'FileSizeMin',
              'FileSizeMax',
              'CreateDate_day',
              'CreateDate_month',
              'CreateDate_year',
              'CreateDate'
            ].contains(entry.key) =>
          normalizeValue<int>(entry.value, int.tryParse),
        (String _)
            when [
              'Duration',
              'Duration_min',
              'Duration_max',
            ].contains(entry.key) =>
          normalizeValue<double>(entry.value, double.tryParse),
        // We may consider adding a normalization for dates ?
        _ => entry.value
      };

      switch (normalizedValue) {
        case (final List<dynamic> val) when normalizedValue.length == 1:
          result[entry.key] = val[0];
        case null:
        case (final List<dynamic> _) when normalizedValue.isEmpty:
          break;
        default:
          result[entry.key] = normalizedValue;
      }
    }

    return result;
  }
}

class TestFiltersLoopback {
  static Future<void> testLB1(TestContext testContext) async {
    for (final testCombination in filterValidTestCases) {
      final queryString =
          ServerCLEntityQuery().getQueryString(map: testCombination);

      final reply = await (await testContext.server
              .filterLoopBack(queryString: queryString))
          .when(validResponse: (items) async {
        // the where clause will be retured, currently we don't test it
        // print(items['rawQuery']);
        return items['loopback'] as Map<String, dynamic>;
      }, errorResponse: (e, {st}) async {
        fail('filterLoopBack Failed $e');
      });

      final mapEquals = const DeepCollectionEquality().equals;
      expect(mapEquals(testCombination.normalized, reply), true,
          reason: 'loopback must return same value\n'
              'input:$testCombination '
              '[normalized: ${testCombination.normalized}] \n'
              'loopback:$reply [normalized: $reply] ');
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
      //print(errorReply);
      expect(errorReply['type'], 'ValidationError',
          reason: 'invalid cases should return ValidationError');
    }
  }

  static Future<void> testLBRandomMap(
      TestContext testContext, Map<String, dynamic> map) async {
    final queryString = ServerCLEntityQuery().getQueryString(map: map);

    final reply = await (await testContext.server
            .filterLoopBack(queryString: queryString))
        .when(validResponse: (items) async {
      // the where clause will be retured, currently we don't test it
      print("rawQuery: ${items['rawQuery']}");
      return items['loopback'] as Map<String, dynamic>;
    }, errorResponse: (e, {st}) async {
      fail('filterLoopBack Failed $e');
    });

    final mapEquals = const DeepCollectionEquality().equals;
    expect(mapEquals(map.normalized, reply), true,
        reason: 'loopback must return same value\n'
            'input:$map '
            '[normalized: ${map.normalized}] \n'
            'loopback:$reply [normalized: $reply] ');
  }
}
