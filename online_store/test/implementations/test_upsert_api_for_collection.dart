/* import 'package:test/test.dart';
import '../framework/framework.dart';

class TestUpsertAPIForCollection {
  static Future<void> testC1(TestContext testContext) async {
    final label1 = randomString(8, prefix: 'test_');
    final entity1 = await testContext.server.validCreate(testContext,
        isCollection: () => true, label: () => label1);
    testContext.validate(entity1,
        id: isNotNull, label: isIn(label1), description: isNull);
  }

  static Future<void> testC2(TestContext testContext) async {
    final label1 = randomString(8, prefix: 'test_');
    const description1 = 'description1';
    final entity1 = await testContext.server.validCreate(testContext,
        isCollection: () => true,
        label: () => label1,
        description: () => description1);
    testContext.validate(entity1,
        id: isNotNull, label: isIn(label1), description: isIn(description1));
  }

  static Future<void> testC3(TestContext testContext) async {
    final label1 = randomString(8, prefix: 'test_');
    const description1 = 'description1';
    final entity1 = await testContext.server.validCreate(testContext,
        isCollection: () => true,
        label: () => label1,
        description: () => description1);
    testContext.validate(entity1,
        id: isNotNull, label: isIn(label1), description: isIn(description1));

    final entity2 = await testContext.server.validCreate(testContext,
        isCollection: () => true,
        label: () => label1,
        description: () => description1);

    expect(entity2, entity1, reason: 'must return the original');
  }

  static Future<void> testC4(TestContext testContext) async {
    final label1 = randomString(8, prefix: 'test_');
    const description1 = 'description1';
    final entity1 = await testContext.server.validCreate(testContext,
        isCollection: () => true,
        label: () => label1,
        description: () => description1);
    testContext.validate(entity1,
        id: isNotNull, label: isIn(label1), description: isIn(description1));
    const description2 = 'description2';
    final entity2 = await testContext.server.validCreate(testContext,
        isCollection: () => true,
        label: () => label1,
        description: () => description2);

    expect(entity2, entity1, reason: 'must return the original');
  }

  static Future<void> testC5(TestContext testContext) async {
    final file = testContext.createImage();
    final label1 = randomString(8, prefix: 'test_');
    final error = await testContext.server.invalidCreate(testContext,
        isCollection: () => true, label: () => label1, fileName: file);
    expect(error['type'], 'CannotAttachFileWithCollectionError');
  }
}
 */
