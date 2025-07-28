// ignore_for_file: avoid_print, print required for testing

import 'package:online_store/src/implementations/cl_server.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:test/test.dart';

import 'framework/framework.dart';
import 'implementations/test_filters.dart';
import 'implementations/test_filters_loopback.dart';

void main() {
  late final CLServer server;
  late final TestContext testContext;
  late final TestFilters testFiltersContext;
  setUpAll(() async {
    server = await TestExtOnCLServer.establishConnection();
    testContext = TestContext(
        tempDir: 'image_test_dir_${randomString(5)}', server: server);
    const resetDB = false;
    // ignore: dead_code enable only when regeneration is required
    if (resetDB) {
      print('${'''
******************************************************************************

This module delete all the entitites in the server repo and creates a
deterministic repo to test the filter functionality. 
This test is designed for TEST SERVERS ONLY.
* DON'T ACCEPT THIS ON LIVE SERVER
* DON'T RUN ANY TEST IN PARALLEL WITH THIS TEST.
******************************************************************************
'''.trim()} ');
      await server.reset();
      testFiltersContext = await TestFilters.uploadRepo(testContext);
      // ignore: dead_code enable only when regeneration is required
    } else {
      final items = await (await server.getAll()).when(
          validResponse: (items) async => items,
          errorResponse: (e, {st}) async {
            fail('getAll Failed');
          });
      testFiltersContext = TestFilters(
          media: items.where((e) => e.isCollection == false).toList(),
          collections: items.where((e) => e.isCollection == true).toList());
    }

    //
  });
  tearDownAll(() async {
    await testContext.dispose(serverCleanup: false);
    // await server.reset();
  });
  setUp(() async {});
  tearDown(() async {});
  group('TestFiltersLoopBack', () {
    test('LB1 valid query filters ',
        () async => TestFiltersLoopback.testLB1(testContext),
        timeout: const Timeout(Duration(hours: 3)));
    test('LB2 invalid query filters ',
        () async => TestFiltersLoopback.testLB2(testContext));
    test('LB3 date queries',
        () async => TestFiltersLoopback.testLBRandomMap(testContext, {}));
  });

  group('filterTest', () {
    test('F1 without any filter',
        () async => testFiltersContext.testF1(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('F2 isCollection - helps to fiter out collections from media',
        () async => testFiltersContext.testF2(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('F3 parentId', () async => testFiltersContext.testF3(testContext),
        timeout: const Timeout(Duration(hours: 1)));
  });

  group('CreateDate', () {
    test('CreateDate',
        () async => testFiltersContext.dateTests['CreateDate']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('CreateDateYY',
        () async => testFiltersContext.dateTests['CreateDateYY']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('CreateDateMM',
        () async => testFiltersContext.dateTests['CreateDateMM']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('CreateDateDD',
        () async => testFiltersContext.dateTests['CreateDateDD']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateFrom',
        () async =>
            testFiltersContext.dateTests['CreateDateFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateYYFrom',
        () async =>
            testFiltersContext.dateTests['CreateDateYYFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateYYMMFrom',
        () async =>
            testFiltersContext.dateTests['CreateDateYYMMFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateYYMMDDFrom',
        () async =>
            testFiltersContext.dateTests['CreateDateYYMMDDFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test(
        'CreateDateTill',
        () async =>
            testFiltersContext.dateTests['CreateDateTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateYYTill',
        () async =>
            testFiltersContext.dateTests['CreateDateYYTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateYYMMTill',
        () async =>
            testFiltersContext.dateTests['CreateDateYYMMTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'CreateDateYYMMDDTill',
        () async =>
            testFiltersContext.dateTests['CreateDateYYMMDDTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
  });
  group('addedDate', () {
    test('addedDate',
        () async => testFiltersContext.dateTests['addedDate']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('addedDateYY',
        () async => testFiltersContext.dateTests['addedDateYY']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('addedDateMM',
        () async => testFiltersContext.dateTests['addedDateMM']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('addedDateDD',
        () async => testFiltersContext.dateTests['addedDateDD']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('addedDateFrom',
        () async => testFiltersContext.dateTests['addedDateFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'addedDateYYFrom',
        () async =>
            testFiltersContext.dateTests['addedDateYYFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'addedDateYYMMFrom',
        () async =>
            testFiltersContext.dateTests['addedDateYYMMFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'addedDateYYMMDDFrom',
        () async =>
            testFiltersContext.dateTests['addedDateYYMMDDFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('addedDateTill',
        () async => testFiltersContext.dateTests['addedDateTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'addedDateYYTill',
        () async =>
            testFiltersContext.dateTests['addedDateYYTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'addedDateYYMMTill',
        () async =>
            testFiltersContext.dateTests['addedDateYYMMTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'addedDateYYMMDDTill',
        () async =>
            testFiltersContext.dateTests['addedDateYYMMDDTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
  });
  group('updatedDate', () {
    test('updatedDate',
        () async => testFiltersContext.dateTests['updatedDate']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('updatedDateYY',
        () async => testFiltersContext.dateTests['updatedDateYY']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('updatedDateMM',
        () async => testFiltersContext.dateTests['updatedDateMM']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test('updatedDateDD',
        () async => testFiltersContext.dateTests['updatedDateDD']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateFrom',
        () async =>
            testFiltersContext.dateTests['updatedDateFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateYYFrom',
        () async =>
            testFiltersContext.dateTests['updatedDateYYFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateYYMMFrom',
        () async =>
            testFiltersContext.dateTests['updatedDateYYMMFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateYYMMDDFrom',
        () async =>
            testFiltersContext.dateTests['updatedDateYYMMDDFrom']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));

    test(
        'updatedDateTill',
        () async =>
            testFiltersContext.dateTests['updatedDateTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateYYTill',
        () async =>
            testFiltersContext.dateTests['updatedDateYYTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateYYMMTill',
        () async =>
            testFiltersContext.dateTests['updatedDateYYMMTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test(
        'updatedDateYYMMDDTill',
        () async =>
            testFiltersContext.dateTests['updatedDateYYMMDDTill']!(testContext),
        timeout: const Timeout(Duration(hours: 1)));
  });
}
