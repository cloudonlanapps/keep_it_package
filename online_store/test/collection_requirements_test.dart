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
  group('Test Collection Interface', () {
    test('C1 can create a collection with label', () async {
      final label1 = randomString(8, prefix: 'test_');
      final entity1 = await server.validCreate(testContext,
          isCollection: () => true, label: () => label1);
      testContext.validate(entity1,
          id: isNotNull, label: isIn(label1), description: isNull);
    });
    test('C2 can create a collection with label and description', () async {
      final label1 = randomString(8, prefix: 'test_');
      const description1 = 'description1';
      final entity1 = await server.validCreate(testContext,
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      testContext.validate(entity1,
          id: isNotNull, label: isIn(label1), description: isIn(description1));
    });
    test("C3 can't create collection with same label, returns the same object",
        () async {
      final label1 = randomString(8, prefix: 'test_');
      const description1 = 'description1';
      final entity1 = await server.validCreate(testContext,
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      testContext.validate(entity1,
          id: isNotNull, label: isIn(label1), description: isIn(description1));

      final entity2 = await server.validCreate(testContext,
          isCollection: () => true,
          label: () => label1,
          description: () => description1);

      expect(entity2, entity1, reason: 'must return the original');
    });
    test(
        "C4 can't create collection with same label and different descripton, the new descripton is ignored",
        () async {
      final label1 = randomString(8, prefix: 'test_');
      const description1 = 'description1';
      final entity1 = await server.validCreate(testContext,
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      testContext.validate(entity1,
          id: isNotNull, label: isIn(label1), description: isIn(description1));
      const description2 = 'description2';
      final entity2 = await server.validCreate(testContext,
          isCollection: () => true,
          label: () => label1,
          description: () => description2);

      expect(entity2, entity1, reason: 'must return the original');
    });

    test("C5 can't create a collection with a file", () async {
      final file = testContext.createImage();
      final label1 = randomString(8, prefix: 'test_');
      final error = await server.invalidCreate(testContext,
          isCollection: () => true, label: () => label1, fileName: file);
      expect(error['type'], 'CannotAttachFileWithCollectionError');
    });
  });
}
