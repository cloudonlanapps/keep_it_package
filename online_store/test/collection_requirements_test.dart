import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'test_modules.dart';
import 'text_ext_on_cl_server.dart';
import 'utils.dart';

/// Add Tests for
/// Creating a collection with file
/// Creating a collection with parentId

void main() async {
  late CLServer server;
  late TestArtifacts testArtifacts;
  late List<int> ids2Delete;

  setUpAll(() async {
    server = await TextExtOnCLServer.establishConnection();
    testArtifacts = TestArtifacts(
        tempDir: 'image_test_dir_${randomString(5)}', server: server);
  });
  tearDownAll(() async {
    await testArtifacts.dispose();
  });

  setUp(() async {});
  tearDown(() async {});
  group('Test Collection Interface', () {
    test('C1 can create a collection with label', () async {
      final label1 = randomString(8, prefix: 'test_');
      final entity1 = await server.validCreate(
          isCollection: () => true, label: () => label1);

      validate(entity1, isNotNull, isIn(label1), isNull);
      final id1 = entity1.id!;
      testArtifacts.entities.add(id1);
      print('created a new collection with id $id1');
    });
    test('C2 can create a collection with label and description', () async {
      final label1 = randomString(8, prefix: 'test_');
      const description1 = 'description1';
      final entity1 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      validate(entity1, isNotNull, isIn(label1), isIn(description1));
      final id1 = entity1.id!;
      testArtifacts.entities.add(id1);
      print('created a new collection with id $id1');
    });
    test("C3 can't create collection with same label, returns the same object",
        () async {
      final label1 = randomString(8, prefix: 'test_');
      const description1 = 'description1';
      final entity1 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      validate(entity1, isNotNull, isIn(label1), isIn(description1));
      final id1 = entity1.id!;
      testArtifacts.entities.add(id1);
      print('created a new collection with id $id1');
      final entity2 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      if (entity2 != entity1) {
        testArtifacts.entities.add(entity2.id!);
      }
      expect(entity2, entity1, reason: 'must return the original');
    });
    test(
        "C4 can't create collection with same label and different descripton, the new descripton is ignored",
        () async {
      final label1 = randomString(8, prefix: 'test_');
      const description1 = 'description1';
      final entity1 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      validate(entity1, isNotNull, isIn(label1), isIn(description1));
      final id1 = entity1.id!;
      testArtifacts.entities.add(id1);
      print('created a new collection with id $id1');
      const description2 = 'description2';
      final entity2 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description2);
      if (entity2 != entity1) {
        final id2 = entity2.id!;
        testArtifacts.entities.add(id2);
        print('created a new collection with id $id2');
      }
      expect(entity2, entity1, reason: 'must return the original');
    });
  });
}

void validate(CLEntity entity, Matcher id, Matcher label, Matcher description) {
  expect(entity.id, id, reason: "response doesn't contains id");
  expect(entity.label, label, reason: "response doesn't contains label");
  expect(entity.description, description,
      reason: 'description is not matching');
}
