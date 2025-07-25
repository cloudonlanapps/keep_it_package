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

    test('F4 CreateDate', () async => testFiltersContext.testF4(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    /* test('F5 CreateDate_year & CreateDate_month',
        () async => testFiltersContext.testF5(testContext),
        timeout: const Timeout(Duration(hours: 1)));
    test('F6 CreateDate_month & CreateDate_day',
        () async => testFiltersContext.testF6(testContext),
        timeout: const Timeout(Duration(hours: 1))); */
  });
}
