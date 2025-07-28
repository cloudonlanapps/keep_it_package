// dart format width=200
// ignore_for_file: avoid_print, print required for testing

import 'dart:io';
import 'dart:math';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';
import 'get_create_date.dart';

@immutable
class DateTestCase {
  const DateTestCase(
      {required this.iters, required this.iterMap, required this.filter});
  final List<dynamic> iters;
  final Map<String, dynamic> Function(dynamic currIter) iterMap;
  final bool Function(CLEntity e, dynamic currIter) filter;
}

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

  Future<void> testCreateDateTemplate(TestContext testContext,
      {required List<dynamic> iters,
      required Map<String, dynamic> Function(dynamic iter) iterMap,
      required bool Function(CLEntity, dynamic date) filter}) async {
    for (final date in iters) {
      await testContext.queryandMatch(
          iterMap(date), allEntities.where((e) => filter(e, date)).toList());
    }
  }

  Map<String, Future<void> Function(TestContext testContext)> get dateTests {
    final testCases =
        <String, Future<void> Function(TestContext testContext)>{};
    for (final entry in createDateTestCases.entries) {
      testCases[entry.key] = (TestContext testContext) =>
          testCreateDateTemplate(testContext,
              iters: entry.value.iters,
              iterMap: entry.value.iterMap,
              filter: entry.value.filter);
    }
    return testCases;
  }

  Map<String, DateTestCase> get createDateTestCases => {
        'CreateDate': DateTestCase(
            iters: createDates,
            iterMap: (dynamic date) =>
                {'CreateDate': (date as DateTime).utcTimeStamp},
            filter: (CLEntity e, dynamic currIter) =>
                e.createDate == currIter as DateTime),
        'CreateDateYY': DateTestCase(
          iters: createDates.map((e) => e.year).toSet().toList(),
          iterMap: (currIter) {
            return {'CreateDateYY': DateTime(currIter as int).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate?.year == currIter;
          },
        ),
        'CreateDateMM': DateTestCase(
          iters: createDates.map((e) => e.month).toSet().toList(),
          iterMap: (currIter) {
            return {
              'CreateDateMM': DateTime(2024, currIter as int).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.createDate?.month == currIter;
          },
        ),
        'CreateDateDD': DateTestCase(
          iters: createDates.map((e) => e.day).toSet().toList(),
          iterMap: (currIter) {
            return {
              'CreateDateDD': DateTime(2024, 1, currIter as int).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.createDate?.day == currIter;
          },
        ),
        'CreateDateFrom': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {'CreateDateFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(currIter as DateTime) >= 0);
          },
        ),
        'CreateDateYYFrom': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {'CreateDateYYFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!
                        .compareTo(DateTime((currIter as DateTime).year)) >=
                    0);
          },
        ),
        'CreateDateYYMMFrom': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {'CreateDateYYMMFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(DateTime(
                        (currIter as DateTime).year, currIter.month)) >=
                    0);
          },
        ),
        'CreateDateYYMMDDFrom': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {
              'CreateDateYYMMDDFrom': (currIter as DateTime).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(DateTime((currIter as DateTime).year,
                        currIter.month, currIter.day)) >=
                    0);
          },
        ),
        'CreateDateTill': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {'CreateDateTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(currIter as DateTime) <= 0);
          },
        ),
        'CreateDateYYTill': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {'CreateDateYYTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(
                        DateTime((currIter as DateTime).year + 1)
                            .subtract(const Duration(microseconds: 1))) <=
                    0);
          },
        ),
        'CreateDateYYMMTill': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {'CreateDateYYMMTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(DateTime(
                            (currIter as DateTime).month == 12
                                ? currIter.year + 1
                                : currIter.year,
                            currIter.month == 12 ? 1 : currIter.month + 1)
                        .subtract(const Duration(microseconds: 1))) <=
                    0);
          },
        ),
        'CreateDateYYMMDDTill': DateTestCase(
          iters: createDates,
          iterMap: (currIter) {
            return {
              'CreateDateYYMMDDTill': (currIter as DateTime).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(DateTime((currIter as DateTime).year,
                            currIter.month, currIter.day)
                        .add(const Duration(days: 1))
                        .subtract(const Duration(microseconds: 1))) <=
                    0);
          },
        ),
        'addedDate': DateTestCase(
            iters: addedDates,
            iterMap: (dynamic date) =>
                {'addedDate': (date as DateTime).utcTimeStamp},
            filter: (CLEntity e, dynamic currIter) =>
                e.addedDate == currIter as DateTime),
        'addedDateYY': DateTestCase(
          iters: addedDates.map((e) => e.year).toSet().toList(),
          iterMap: (currIter) {
            return {'addedDateYY': DateTime(currIter as int).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.year == currIter;
          },
        ),
        'addedDateMM': DateTestCase(
          iters: addedDates.map((e) => e.month).toSet().toList(),
          iterMap: (currIter) {
            return {
              'addedDateMM': DateTime(2024, currIter as int).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.addedDate.month == currIter;
          },
        ),
        'addedDateDD': DateTestCase(
          iters: addedDates.map((e) => e.day).toSet().toList(),
          iterMap: (currIter) {
            return {
              'addedDateDD': DateTime(2024, 1, currIter as int).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.addedDate.day == currIter;
          },
        ),
        'addedDateFrom': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(currIter as DateTime) >= 0;
          },
        ),
        'addedDateYYFrom': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateYYFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate
                    .compareTo(DateTime((currIter as DateTime).year)) >=
                0;
          },
        ),
        'addedDateYYMMFrom': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateYYMMFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(
                    DateTime((currIter as DateTime).year, currIter.month)) >=
                0;
          },
        ),
        'addedDateYYMMDDFrom': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateYYMMDDFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(DateTime((currIter as DateTime).year,
                    currIter.month, currIter.day)) >=
                0;
          },
        ),
        'addedDateTill': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(currIter as DateTime) <= 0;
          },
        ),
        'addedDateYYTill': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateYYTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(
                    DateTime((currIter as DateTime).year + 1)
                        .subtract(const Duration(microseconds: 1))) <=
                0;
          },
        ),
        'addedDateYYMMTill': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateYYMMTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(DateTime(
                        (currIter as DateTime).month == 12
                            ? currIter.year + 1
                            : currIter.year,
                        currIter.month == 12 ? 1 : currIter.month + 1)
                    .subtract(const Duration(microseconds: 1))) <=
                0;
          },
        ),
        'addedDateYYMMDDTill': DateTestCase(
          iters: addedDates,
          iterMap: (currIter) {
            return {'addedDateYYMMDDTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(DateTime((currIter as DateTime).year,
                        currIter.month, currIter.day)
                    .add(const Duration(days: 1))
                    .subtract(const Duration(microseconds: 1))) <=
                0;
          },
        ),
        'updatedDate': DateTestCase(
            iters: updatedDates,
            iterMap: (dynamic date) =>
                {'updatedDate': (date as DateTime).utcTimeStamp},
            filter: (CLEntity e, dynamic currIter) =>
                e.updatedDate == currIter as DateTime),
        'updatedDateYY': DateTestCase(
          iters: updatedDates.map((e) => e.year).toSet().toList(),
          iterMap: (currIter) {
            return {'updatedDateYY': DateTime(currIter as int).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.year == currIter;
          },
        ),
        'updatedDateMM': DateTestCase(
          iters: updatedDates.map((e) => e.month).toSet().toList(),
          iterMap: (currIter) {
            return {
              'updatedDateMM': DateTime(2024, currIter as int).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.updatedDate.month == currIter;
          },
        ),
        'updatedDateDD': DateTestCase(
          iters: updatedDates.map((e) => e.day).toSet().toList(),
          iterMap: (currIter) {
            return {
              'updatedDateDD': DateTime(2024, 1, currIter as int).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.updatedDate.day == currIter;
          },
        ),
        'updatedDateFrom': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {'updatedDateFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(currIter as DateTime) >= 0;
          },
        ),
        'updatedDateYYFrom': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {'updatedDateYYFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate
                    .compareTo(DateTime((currIter as DateTime).year)) >=
                0;
          },
        ),
        'updatedDateYYMMFrom': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {'updatedDateYYMMFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(
                    DateTime((currIter as DateTime).year, currIter.month)) >=
                0;
          },
        ),
        'updatedDateYYMMDDFrom': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {
              'updatedDateYYMMDDFrom': (currIter as DateTime).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(DateTime((currIter as DateTime).year,
                    currIter.month, currIter.day)) >=
                0;
          },
        ),
        'updatedDateTill': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {'updatedDateTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(currIter as DateTime) <= 0;
          },
        ),
        'updatedDateYYTill': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {'updatedDateYYTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(
                    DateTime((currIter as DateTime).year + 1)
                        .subtract(const Duration(microseconds: 1))) <=
                0;
          },
        ),
        'updatedDateYYMMTill': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {'updatedDateYYMMTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(DateTime(
                        (currIter as DateTime).month == 12
                            ? currIter.year + 1
                            : currIter.year,
                        currIter.month == 12 ? 1 : currIter.month + 1)
                    .subtract(const Duration(microseconds: 1))) <=
                0;
          },
        ),
        'updatedDateYYMMDDTill': DateTestCase(
          iters: updatedDates,
          iterMap: (currIter) {
            return {
              'updatedDateYYMMDDTill': (currIter as DateTime).utcTimeStamp
            };
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(DateTime((currIter as DateTime).year,
                        currIter.month, currIter.day)
                    .add(const Duration(days: 1))
                    .subtract(const Duration(microseconds: 1))) <=
                0;
          },
        ),
      };

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

  List<DateTime> get addedDates =>
      allEntities.map((e) => e.addedDate).toSet().toList()..sort();

  List<DateTime> get updatedDates =>
      allEntities.map((e) => e.updatedDate).toSet().toList()..sort();

  List<CLEntity> get allEntities => [...collections, ...media]
      .where((e) => e != null)
      .toList()
      .cast<CLEntity>();
  List<CLEntity> get validCollections =>
      collections.where((e) => e != null).toList().cast<CLEntity>();
}
