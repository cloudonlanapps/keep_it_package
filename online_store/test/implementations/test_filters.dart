// ignore_for_file: avoid_print, print required for testing

import 'dart:io';
import 'dart:math';

import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';
import 'get_create_date.dart';

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

  static Future<TestFilters> uploadRepo(TestContext testContext) async {
    final random2 = DeterministicRandomString(0x54321);
    final random = Random(0x12345);
    final collections = <CLEntity?>[null];
    for (var i = 0; i < 20; i++) {
      print('\rGenerating Collections: $i'.padRight(60));
      final label1 = random2.nextString(prefix: 'test_');
      final entity1 = await testContext.server.validCreate(testContext,
          isCollection: () => true, label: () => label1);
      testContext.validate(entity1,
          id: isNotNull, label: equals(label1), description: isNull);
      collections.add(entity1);
    }
    final entitites = <CLEntity>[];
    // Create a Directory object
    final directory =
        Directory('/Users/anandasarangaram/Work/github/generated_media');
    if (directory.existsSync()) {
      print('Traversing files in: ${directory.path}');

      final files = directory.listSync(recursive: true);

      for (final (i, file) in files.indexed) {
        if (file is File && !file.path.endsWith('.DS_Store')) {
          print('$i:  ${file.path}');
          final parentId = collections[random.nextInt(collections.length)]?.id;
          final entity1 = await testContext.server.validCreate(testContext,
              fileName: file.path,
              parentId: parentId == null ? () => 0 : () => parentId);
          final date = await getCreateDate(file.absolute.path);
          if (date == null) {
            testContext.validate(entity1,
                id: isNotNull, md5: isNotNull, createDate: isNull);
          } else {
            testContext.validate(entity1,
                id: isNotNull, md5: isNotNull, createDate: isNotNull);
          }
          expect(entity1.createDate, date,
              reason:
                  "${entity1.id} createDate didn't match: set: $date, got: ${entity1.createDate}");
          entitites.add(entity1);
        }
      }
    } else {
      print('Error: Directory "${directory.path}" does not exist.');
    }
    print('Generated ${collections.length + entitites.length} items}');
    return TestFilters(collections: collections, media: entitites);
  }

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

      for (final date in createDates) {
        await testContext.queryandMatch({'CreateDate': date},
            allEntities.where((e) => e.createDate == date).toList());
      }
    }
  }

  Future<void> testF5(
    TestContext testContext,
  ) async {
    for (final yearEntry in yearMonth.entries) {
      for (final month in yearEntry.value) {
        await testContext.queryandMatch(
            {'CreateDate_year': yearEntry.key, 'CreateDate_month': month},
            allEntities
                .where((e) =>
                    e.createDate != null &&
                    e.createDate!.year == yearEntry.key &&
                    e.createDate!.month == month)
                .toList());
      }
    }
  }

  Future<void> testF6(
    TestContext testContext,
  ) async {
    for (final monthEntry in monthDay.entries) {
      for (final day in monthEntry.value) {
        await testContext.queryandMatch(
            {'CreateDate_month': monthEntry.key, 'CreateDate_day': day},
            allEntities
                .where((e) =>
                    e.createDate != null &&
                    e.createDate!.month == monthEntry.key &&
                    e.createDate!.day == day)
                .toList());
      }
    }
  }

  Map<int, Set<int>> get monthDay => <int, Set<int>>{}
    ..addEntries(createDates.map((date) => MapEntry(date.month, {date.day})));

  Map<int, Set<int>> get yearMonth => <int, Set<int>>{}
    ..addEntries(createDates.map((date) => MapEntry(date.year, {date.month})));

  Set<DateTime> get createDates => allEntities
      .where((e) => e.createDate != null)
      .map((e) => e.createDate!)
      .toSet();

  List<CLEntity> get allEntities => [...collections, ...media]
      .where((e) => e != null)
      .toList()
      .cast<CLEntity>();
  List<CLEntity> get validCollections =>
      collections.where((e) => e != null).toList().cast<CLEntity>();
}
