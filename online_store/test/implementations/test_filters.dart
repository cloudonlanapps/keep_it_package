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

  Future<void> testCreateDate(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      await testContext.queryandMatch({'CreateDate': date.utcTimeStamp},
          allEntities.where((e) => e.createDate == date).toList());
    }
  }

  Future<void> testCreateDateYY(
    TestContext testContext,
  ) async {
    final years = createDates.map((e) => e.year).toSet();
    for (final year in years) {
      await testContext.queryandMatch(
          {'CreateDateYY': DateTime(year).utcTimeStamp},
          allEntities.where((e) => e.createDate?.year == year).toList());
    }
  }

  Future<void> testCreateDateMM(
    TestContext testContext,
  ) async {
    final months = createDates.map((e) => e.month).toSet();
    for (final month in months) {
      final equivalentDatetime = DateTime(2024, month).utcTimeStamp;
      await testContext.queryandMatch({'CreateDateMM': equivalentDatetime},
          allEntities.where((e) => e.createDate?.month == month).toList());
    }
  }

  Future<void> testCreateDateDD(
    TestContext testContext,
  ) async {
    final days = createDates.map((e) => e.day).toSet();
    for (final day in days) {
      final equivalentDatetime = DateTime(2024, 1, day).utcTimeStamp;
      await testContext.queryandMatch({'CreateDateDD': equivalentDatetime},
          allEntities.where((e) => e.createDate?.day == day).toList());
    }
  }

  Future<void> testCreateDateFrom(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      await testContext.queryandMatch(
          {'CreateDateFrom': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null && (e.createDate!.compareTo(date) >= 0))
              .toList());
    }
  }

  Future<void> testCreateDateYYFrom(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      final equivalentDatetime = DateTime(date.year);
      await testContext.queryandMatch(
          {'CreateDateYYFrom': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null &&
                  (e.createDate!.compareTo(equivalentDatetime) >= 0))
              .toList());
    }
  }

  Future<void> testCreateDateYYMMFrom(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      final equivalentDatetime = DateTime(date.year, date.month);
      await testContext.queryandMatch(
          {'CreateDateYYMMFrom': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null &&
                  (e.createDate!.compareTo(equivalentDatetime) >= 0))
              .toList());
    }
  }

  Future<void> testCreateDateYYMMDDFrom(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      final equivalentDatetime = DateTime(date.year, date.month, date.day);
      await testContext.queryandMatch(
          {'CreateDateYYMMDDFrom': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null &&
                  (e.createDate!.compareTo(equivalentDatetime) >= 0))
              .toList());
    }
  }

  Future<void> testCreateDateTill(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      await testContext.queryandMatch(
          {'CreateDateTill': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null && (e.createDate!.compareTo(date) <= 0))
              .toList());
    }
  }

  Future<void> testCreateDateYYTill(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      final equivalentDatetime =
          DateTime(date.year + 1).subtract(const Duration(microseconds: 1));

      await testContext.queryandMatch(
          {'CreateDateYYTill': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null &&
                  (e.createDate!.compareTo(equivalentDatetime) <= 0))
              .toList());
    }
  }

  Future<void> testCreateDateYYMMTill(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      final equivalentDatetime = DateTime(
              date.month == 12 ? date.year + 1 : date.year,
              date.month == 12 ? 1 : date.month + 1)
          .subtract(const Duration(microseconds: 1));

      await testContext.queryandMatch(
          {'CreateDateYYMMTill': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null &&
                  (e.createDate!.compareTo(equivalentDatetime) <= 0))
              .toList());
    }
  }

  Future<void> testCreateDateYYMMDDTill(
    TestContext testContext,
  ) async {
    for (final date in createDates) {
      final equivalentDatetime = DateTime(date.year, date.month, date.day)
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      await testContext.queryandMatch(
          {'CreateDateYYMMDDTill': date.utcTimeStamp},
          allEntities
              .where((e) =>
                  e.createDate != null &&
                  (e.createDate!.compareTo(equivalentDatetime) <= 0))
              .toList());
    }
  }

  Map<int, Set<int>> get monthDay => <int, Set<int>>{}
    ..addEntries(createDates.map((date) => MapEntry(date.month, {date.day})));

  Map<int, Set<int>> get yearMonth => <int, Set<int>>{}
    ..addEntries(createDates.map((date) => MapEntry(date.year, {date.month})));

  List<DateTime> get createDates => allEntities
      .where((e) => e.createDate != null)
      .map((e) => e.createDate!)
      .toSet()
      .toList()
    ..sort();

  List<CLEntity> get allEntities => [...collections, ...media]
      .where((e) => e != null)
      .toList()
      .cast<CLEntity>();
  List<CLEntity> get validCollections =>
      collections.where((e) => e != null).toList().cast<CLEntity>();
}
