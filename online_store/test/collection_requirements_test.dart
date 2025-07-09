// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'text_ext_on_cl_server.dart';
import 'utils.dart';

/// Add Tests for
/// Creating a collection with file
/// Creating a collection with parentId

void main() async {
  late CLServer server;
  late Directory tempDir;
  late List<int> ids2Delete;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('image_test_dir_');
    print('Created temporary directory: ${tempDir.path}');
  });
  tearDownAll(() async {
    print('Deleting temporary directory: ${tempDir.path}');
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    try {
      final url = StoreURL(Uri.parse('http://127.0.0.1:5001/'),
          identity: null, label: null);

      server = await CLServer(storeURL: url).withId();
      if (!server.hasID) {
        fail('Connection Failed, could not get the server Id');
      }
    } catch (e) {
      fail('Failed: $e');
    }
    ids2Delete = [];
  });
  tearDown(() async {
    await server.cleanupEntity(ids2Delete);
  });
  group('Test Collection Interface', () {
    test('C1 can create a collection with label', () async {
      final label1 = randomString(8, prefix: 'test_');
      final entity1 = await server.validCreate(
          isCollection: () => true, label: () => label1);

      validate(entity1, isNotNull, isIn(label1), isNull);
      final id1 = entity1.id!;
      ids2Delete.add(id1);
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
      ids2Delete.add(id1);
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
      ids2Delete.add(id1);
      print('created a new collection with id $id1');
      final entity2 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description1);
      if (entity2 != entity1) {
        ids2Delete.add(entity2.id!);
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
      ids2Delete.add(id1);
      print('created a new collection with id $id1');
      const description2 = 'description2';
      final entity2 = await server.validCreate(
          isCollection: () => true,
          label: () => label1,
          description: () => description2);
      if (entity2 != entity1) {
        final id2 = entity2.id!;
        ids2Delete.add(id2);
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
