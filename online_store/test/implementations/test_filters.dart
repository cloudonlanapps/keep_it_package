// ignore_for_file: avoid_print, print required for testing

import 'dart:math';

import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';

class DeterministicRandomString {
  DeterministicRandomString(this.seed) : random = Random(seed);

  final int seed;
  final chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random random;

  String nextString({String prefix = '', String suffix = ''}) {
    final randString = String.fromCharCodes(Iterable.generate(
      8,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));

    return '$prefix$randString$suffix';
  }
}

class TestFilters {
  TestFilters({required this.media, required this.collections});
  final List<CLEntity> media;
  final List<CLEntity?> collections;

  static Future<TestFilters> setupRepo(TestContext testContext) async {
    final random = Random(0x12345);
    final random2 = DeterministicRandomString(0x54321);

    final now = DateTime(2024, 12, 31, 23, 59, 59);
    final start = DateTime(2020);
    final difference = now.difference(start).inSeconds;

    final collections = <CLEntity?>[null];
    for (var i = 0; i < 4; i++) {
      print('\rGenerating Collections: $i'.padRight(60));
      final label1 = random2.nextString(prefix: 'test_');
      final entity1 = await testContext.server.validCreate(testContext,
          isCollection: () => true, label: () => label1);
      testContext.validate(entity1,
          id: isNotNull, label: equals(label1), description: isNull);
      collections.add(entity1);
    }
    final entitites = <CLEntity>[];
    // add jpg images with CreateDate
    for (var i = 0; i < 40; i++) {
      final parentId = collections[random.nextInt(collections.length)]?.id;
      final randomSeconds = random.nextInt(difference);
      final randomDate = start.add(Duration(seconds: randomSeconds));
      final dateOnly =
          DateTime(randomDate.year, randomDate.month, randomDate.day);

      for (var j = 0; j < random.nextInt(20); j++) {
        final randomSeconds = random.nextInt(24 * 60 * 60);
        final date = dateOnly.add(Duration(seconds: randomSeconds));
        print('\rGenerating JPG Media with CreateDate: $date'.padRight(60));
        final imageFile = await testContext.createImageWithDateTime(date);
        final entity1 = await testContext.server.validCreate(testContext,
            fileName: imageFile,
            parentId: parentId == null ? () => 0 : () => parentId);

        testContext.validate(entity1,
            id: isNotNull, md5: isNotNull, createDate: isNotNull);
        expect(entity1.createDate, date,
            reason:
                "${entity1.id} createDate didn't match: set: $date, got: ${entity1.createDate}");
        entitites.add(entity1);
      }
    }
    // add few jpg images without any createDate
    for (var i = 0; i < 5; i++) {
      print('\rGenerating JPG Media without CreateDate: $i'.padRight(60));
      final parentId = collections[random.nextInt(collections.length)]?.id;
      final imageFile = testContext.createImage();
      final entity1 = await testContext.server.validCreate(testContext,
          fileName: imageFile,
          parentId: parentId == null ? () => 0 : () => parentId);

      testContext.validate(
        entity1,
        id: isNotNull,
        md5: isNotNull,
      );

      entitites.add(entity1);
    }
    print('Generated ${collections.length + entitites.length} items}');
    return TestFilters(collections: collections, media: entitites);
  }

  Future<void> testF1(
    TestContext testContext,
  ) async {
    await testContext.queryandMatch({}, allEntities);
  }

  Future<void> testF2(
    TestContext testContext,
  ) async {
    {
      await testContext.queryandMatch({'isCollection': true}, validCollections);
      await testContext.queryandMatch({'isCollection': false}, media);
    }
  }

  Future<void> testF3(
    TestContext testContext,
  ) async {
    {
      for (final collection in collections) {
        await testContext.queryandMatch(
            {'parentId': collection?.id ?? '__null__'},
            allEntities.where((e) => e.parentId == collection?.id).toList());
      }
    }
  }

  Future<void> testF4(
    TestContext testContext,
  ) async {
    {
      await testContext.queryandMatch({'CreateDate': '__null__'},
          allEntities.where((e) => e.createDate == null).toList());
      await testContext.queryandMatch({'CreateDate': '__notnull__'},
          allEntities.where((e) => e.createDate != null).toList());
    }
  }

  List<CLEntity> get allEntities => [...collections, ...media]
      .where((e) => e != null)
      .toList()
      .cast<CLEntity>();
  List<CLEntity> get validCollections =>
      collections.where((e) => e != null).toList().cast<CLEntity>();
}
