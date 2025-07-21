import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:test/test.dart';

import 'framework/framework.dart';
import 'implementations/test_date_time_original.dart';
import 'implementations/test_filters_loopback.dart';
import 'implementations/test_get_apis.dart';
import 'implementations/test_upsert_api_for_collection.dart';
import 'implementations/test_upsert_api_for_media.dart';

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
  group('TestUpsertAPIForCollection', () {
    test('C1 can create a collection with label',
        () async => TestUpsertAPIForCollection.testC1(testContext));
    test('C2 can create a collection with label and description',
        () async => TestUpsertAPIForCollection.testC2(testContext));
    test("C3 can't create collection with same label, returns the same object",
        () async => TestUpsertAPIForCollection.testC3(testContext));
    test(
        "C4 can't create collection with same label and different descripton, the new descripton is ignored",
        () async => TestUpsertAPIForCollection.testC4(testContext));

    test("C5 can't create a collection with a file",
        () async => TestUpsertAPIForCollection.testC5(testContext));
  });
  group('TestUpsertAPIForMedia', () {
    test("M1 can't create a media without file",
        () async => TestUpsertAPIForMedia.testM1(testContext));
    test('M2 can create a media with only file',
        () async => TestUpsertAPIForMedia.testM2(testContext));
    test('M3 can replace a media ',
        () async => TestUpsertAPIForMedia.testM3(testContext));
    test('M4 can create with label and update it ',
        () async => TestUpsertAPIForMedia.testM4(testContext));
    test("M5 can't create media with same file, returns the same object",
        () async => TestUpsertAPIForMedia.testM5(testContext));
    test("M6 Can't create duplicate to existing item, even by updating",
        () async => TestUpsertAPIForMedia.testM6(testContext));
  });
  group('TestGetAPIs', () {
    test(
        'R1 test getAll, and confirm all the items recently created present in it',
        () async => TestGetAPIs.testR1(testContext));
    test('R2 `getByID` returns valid entity if found',
        () async => TestGetAPIs.testR2(testContext));
    test('R3 `getByID` returns NotFound error when the item is not present',
        () async => TestGetAPIs.testR3(testContext));
    test('R4 `get` with  label returns valid entity if found for collection',
        () async => TestGetAPIs.testR4(testContext));
    test('R5 `get` with  md5 returns valid entity if found for media',
        () async => TestGetAPIs.testR5(testContext));
  });

  group('TestFiltersLoopBack', () {
    test('LB1 valid query filters ',
        () async => TestFiltersLoopback.testLB1(testContext));
    test('LB1 invalid query filters ',
        () async => TestFiltersLoopback.testLB2(testContext));
  });

  group('exif', () {
    test('DateTimeOriginal',
        () async => TestDateTimeOriginal.testDT1(testContext),
        timeout: const Timeout(Duration(hours: 1)));
  });
}
