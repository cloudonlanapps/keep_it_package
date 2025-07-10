import 'dart:io';

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
  group('Test Media Interface', () {
    test("M1 can't create a media without file", () async {
      final label1 = randomString(8, prefix: 'test_');
      final error = await server.invalidCreate(testContext,
          isCollection: () => false, label: () => label1);

      expect(error['type'], 'MediaMustHaveMediaFile',
          reason: 'mediaFile is not present in the returned error');
    });
    test('M2 can create a media with only file', () async {
      final fileName1 = testContext.createImage();
      final entity1 =
          await server.validCreate(testContext, fileName: fileName1);
      testContext.validate(entity1, id: isNotNull, md5: isNotNull);
    });

    test('M3 can replace a media ', () async {
      final fileName1 = testContext.createImage();
      final entity1 =
          await server.validCreate(testContext, fileName: fileName1);
      testContext.validate(entity1,
          id: isNotNull,
          md5: isNotNull,
          fileSize: equals(File(fileName1).lengthSync()));
      final fileName2 = testContext.createImage();
      final entity2 = await server.validCreate(testContext,
          id: entity1.id, fileName: fileName2);
      testContext.validate(entity2,
          id: isNotNull,
          md5: isNotNull,
          fileSize: equals(File(fileName2).lengthSync()));
    });
    test('M4 can create with label and update it ', () async {
      final fileName1 = testContext.createImage();
      final label1 = randomString(8);
      final entity1 = await server.validCreate(
        testContext,
        fileName: fileName1,
        label: () => label1,
      );
      testContext.validate(entity1,
          id: isNotNull,
          md5: isNotNull,
          label: equals(label1),
          fileSize: equals(File(fileName1).lengthSync()));

      final label2 = randomString(10);
      final entity2 = await server.validCreate(
        testContext,
        id: entity1.id,
        label: () => label2,
      );
      testContext.validate(entity2,
          id: isNotNull,
          md5: isNotNull,
          label: equals(label2),
          fileSize: equals(File(fileName1).lengthSync()));
    });
    test("M5 can't create media with same file, returns the same object",
        () async {
      final fileName1 = testContext.createImage();
      final entity1 = await server.validCreate(
        testContext,
        fileName: fileName1,
      );
      testContext.validate(entity1,
          id: isNotNull,
          md5: isNotNull,
          label: isNull,
          fileSize: equals(File(fileName1).lengthSync()));

      final entity2 = await server.validCreate(
        testContext,
        fileName: fileName1,
      );
      expect(entity2, entity1,
          reason:
              "M5 can't create media with same file, can't return return different object");

      //final fileName2 = testContext.createImage();
    });
    test("M6 Can't create duplicate to existing item, even by updating",
        () async {
      final fileName1 = testContext.createImage();
      final fileName2 = testContext.createImage();

      final entity1 = await server.validCreate(
        testContext,
        fileName: fileName1,
      );
      final entity2 = await server.validCreate(
        testContext,
        fileName: fileName2,
      );

      testContext
        ..validate(entity1,
            id: isNotNull,
            md5: isNotNull,
            label: isNull,
            fileSize: equals(File(fileName1).lengthSync()))
        ..validate(entity2,
            id: isNotNull,
            md5: isNotNull,
            label: isNull,
            fileSize: equals(File(fileName2).lengthSync()));

      final error = await server.invalidCreate(
        id: entity1.id,
        testContext,
        fileName: fileName2,
      );
      expect(error['type'], 'MD5DuplicateItemError',
          reason: "Can't create duplicate to existing item, even by updating");

      //final fileName2 = testContext.createImage();
    });
  });
}
