import 'dart:io';
import 'package:test/test.dart';
import '../framework/framework.dart';

class TestUpsertAPIForMedia {
  static Future<void> testM1(TestContext testContext) async {
    final label1 = randomString(8, prefix: 'test_');
    final error = await testContext.server.invalidCreate(testContext,
        isCollection: () => false, label: () => label1);

    expect(error['type'], 'MediaMustHaveMediaFile',
        reason: 'mediaFile is not present in the returned error');
  }

  static Future<void> testM2(TestContext testContext) async {
    final fileName1 = testContext.createImage();
    final entity1 =
        await testContext.server.validCreate(testContext, fileName: fileName1);
    testContext.validate(entity1, id: isNotNull, md5: isNotNull);
  }

  static Future<void> testM3(TestContext testContext) async {
    final fileName1 = testContext.createImage();
    final entity1 =
        await testContext.server.validCreate(testContext, fileName: fileName1);
    testContext.validate(entity1,
        id: isNotNull,
        md5: isNotNull,
        fileSize: equals(File(fileName1).lengthSync()));
    final fileName2 = testContext.createImage();
    final entity2 = await testContext.server
        .validCreate(testContext, id: entity1.id, fileName: fileName2);
    testContext.validate(entity2,
        id: isNotNull,
        md5: isNotNull,
        fileSize: equals(File(fileName2).lengthSync()));
  }

  static Future<void> testM4(TestContext testContext) async {
    final fileName1 = testContext.createImage();
    final label1 = randomString(8);
    final entity1 = await testContext.server.validCreate(
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
    final entity2 = await testContext.server.validCreate(
      testContext,
      id: entity1.id,
      label: () => label2,
    );
    testContext.validate(entity2,
        id: isNotNull,
        md5: isNotNull,
        label: equals(label2),
        fileSize: equals(File(fileName1).lengthSync()));
  }

  static Future<void> testM5(TestContext testContext) async {
    final fileName1 = testContext.createImage();
    final entity1 = await testContext.server.validCreate(
      testContext,
      fileName: fileName1,
    );
    testContext.validate(entity1,
        id: isNotNull,
        md5: isNotNull,
        label: isNull,
        fileSize: equals(File(fileName1).lengthSync()));

    final entity2 = await testContext.server.validCreate(
      testContext,
      fileName: fileName1,
    );
    expect(entity2, entity1,
        reason:
            "M5 can't create media with same file, can't return return different object");

    //final fileName2 = testContext.createImage();
  }

  static Future<void> testM6(TestContext testContext) async {
    final fileName1 = testContext.createImage();
    final fileName2 = testContext.createImage();

    final entity1 = await testContext.server.validCreate(
      testContext,
      fileName: fileName1,
    );
    final entity2 = await testContext.server.validCreate(
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

    final error = await testContext.server.invalidCreate(
      id: entity1.id,
      testContext,
      fileName: fileName2,
    );
    expect(error['type'], 'MD5DuplicateItemError',
        reason: "Can't create duplicate to existing item, even by updating");

    //final fileName2 = testContext.createImage();
  }
}
