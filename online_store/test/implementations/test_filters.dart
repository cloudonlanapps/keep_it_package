// dart format width=200
// ignore_for_file: avoid_print, print required for testing

import 'dart:io';
import 'dart:math';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:online_store/src/models/entity_server.dart';

import 'package:test/test.dart';

import '../framework/framework.dart';
import 'get_create_date.dart';
import 'test_mime_types.dart';

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
  TestFilters({
    required this.media,
    required this.collections,
    this.descriptionPrefixesUsed = const [],
    this.labelPrefixesUsed = const [],
  });
  final List<CLEntity> media;
  final List<CLEntity?> collections;
  final List<String?> labelPrefixesUsed;
  final List<String?> descriptionPrefixesUsed;
  static final startsWith = <String>[
    'FamSnap_2024Q3',
    'Memories_V2A',
    'KidsJoy_001',
    'Holiday_Moments_X',
    'MyAlbum_2025B',
    'SweetHome_Pics',
    'Generations_Tag',
    'Precious_Shots_C',
    'Heartfelt_Views',
    'LittleOnes_Fun',
    'OurJourney_P1',
    'GoldenYears_77',
    'Laughter_Live_A',
    'Cherish_Today_3',
    'BrightSmiles_Z',
    'Childhood_Days_1',
    'Gatherings_V4',
    'Milestone_2025',
    'Unforgettable_Y',
    'FamilyBond_09',
    'WarmHugs_Series',
    'Joyful_Life_B',
    'Legacy_Pix_K2',
    'Growth_Story_D',
    'HappyTimes_23',
    'PureBliss_Photo',
    'Everyday_Magic',
    'SpecialDay_Cap',
    'Future_Past_Now',
    'Forever_Frame_W'
  ];
  static final contains = [
    'MemoriesCap_F1',
    'SharedMoments_03',
    'Heartprints_V6',
    'OurLegacy_Alpha',
    'Cherished_Pix_2',
    'Gathered_Views_A',
    'Warmth_InFrame',
    'Connection_Snap',
    'LifeBlooms_2025',
    'EverydayJoy_Beta',
    'HomeStories_07',
    'LovedOnes_Album',
    'Smiles_Forever_C',
    'GrowingUp_Series',
    'FamilyTales_Ch1',
    'Precious_Glimpse',
    'JoyfulVibes_Pix',
    'Bonding_Moments_X',
    'Timeless_Frames',
    'KindredSpirits_9',
    'SweetEchoes_V3',
    'Snapshot_Bliss_R',
    'Affection_Lens',
    'Roots_AndWings_1',
    'GoldenHours_Fam',
    'Candid_Gems_005',
    'Adventures_Together',
    'PureHeart_Visuals',
    'Chapter_One_Pics',
    'Everlasting_View'
  ];
  static final duplicates = [
    'PicturePerfect_G1',
    'FamilyChron_V2',
    'SweetMemories_A01',
    'LifeCaptured_S2',
    'JoyfulEssence_X',
    'Beloved_Images_04',
    'OurJourney_Pics',
    'Heartfelt_Clicks',
    'Generations_Lens',
    'WarmFlashes_789',
    'Precious_Album_B',
    'HomeScene_Moments',
    'Laughter_Frames_C',
    'Cherished_Echoes_1',
    'GoldenLight_Views',
    'Childhood_Snaps_P',
    'Together_Always_Z',
    'HappyHeart_Vis_Q',
    'Unfolding_Tales_5',
    'PureMoments_Photo',
    'Connection_Vibe_D',
    'Evergreen_Photos',
    'Legacy_Captures_K',
    'Growth_And_Grace',
    'BrightFutures_00',
    'FamilyCircle_Vis',
    'Candid_Treasures',
    'Everyday_Love_E',
    'Milestone_Mem_V3',
    'Eternal_Reflects'
  ];

  static List<String?> generateRandomStrings(int n, {bool haveNull = false}) {
    final random = Random(0xABCDEF);
    final result = <String?>[];

    for (var i = 0; i < n; i++) {
      final choice = random.nextInt(6);

      result.add(switch (choice) {
        0 => duplicates[random.nextInt(startsWith.length)],
        1 => startsWith[random.nextInt(startsWith.length)] +
            _randomString(random, length: 4 + random.nextInt(6)),
        2 => _randomString(random, length: 4 + random.nextInt(6)) +
            contains[random.nextInt(startsWith.length)] +
            _randomString(random, length: 4 + random.nextInt(6)),
        5 => null,
        _ => _randomString(random, length: 4 + random.nextInt(16)),
      });
    }

    return result;
  }

  static String _randomString(Random random, {int length = 6}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz'
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        '0123456789 '; // added space at the end
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

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

      final randomLables = generateRandomStrings(files.length, haveNull: true);
      final randomDescription =
          generateRandomStrings(files.length, haveNull: true);

      for (final (i, file) in files.indexed) {
        if (file is File && !file.path.endsWith('.DS_Store')) {
          print('$i:  ${file.path}');
          final parentId = collections[random.nextInt(collections.length)]?.id;
          final label = randomLables[i];
          final description = randomDescription[i];
          final entity1 = await testContext.server.validCreate(testContext,
              fileName: file.path,
              parentId: parentId == null ? () => 0 : () => parentId,
              label: label != null ? () => label : null,
              description: description != null ? () => description : null);
          final date = await getCreateDate(file.absolute.path);

          testContext.validate(entity1,
              id: isNotNull,
              md5: isNotNull,
              parentId: parentId == null ? isNull : isNotNull,
              createDate: date == null ? isNull : isNotNull,
              label: label == null ? isNull : isNotNull,
              description: description == null ? isNull : isNotNull);

          expect(entity1.parentId, parentId,
              reason:
                  "${entity1.parentId} parentId didn't match: set: $parentId, got: ${entity1.parentId}");

          expect(entity1.label, label,
              reason:
                  "${entity1.id} label didn't match: set: $label, got: ${entity1.label}");
          expect(entity1.description, description,
              reason:
                  "${entity1.id} description didn't match: set: $description, got: ${entity1.description}");
          expect(entity1.createDate, date,
              reason:
                  "${entity1.id} createDate didn't match: set: $date, got: ${entity1.createDate}");
          entitites.add(entity1);
        }
      }
      // Delete random 30 to test 'isDeleted'
      final items2Delete = entitites.shuffled().take(30);
      for (final item in items2Delete) {
        await testContext.server.toBin(item.id!);
      }
      print('Generated ${collections.length + entitites.length} items}');
      return TestFilters(
          collections: collections,
          media: entitites
              .map((e) => items2Delete.map((e) => e.id).contains(e.id)
                  ? e.copyWith(isDeleted: true)
                  : e)
              .toList(),
          descriptionPrefixesUsed: randomDescription,
          labelPrefixesUsed: randomLables);
    } else {
      print('Error: Directory "${directory.path}" does not exist.');
      print('Generated ${collections.length + entitites.length} items}');
      return TestFilters(collections: collections, media: entitites);
    }
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

  Future<void> testGetAll(
    TestContext testContext,
  ) async {
    await testContext.queryandMatch({}, allEntities);
  }

  Future<void> testIsCollection(
    TestContext testContext,
  ) async {
    {
      await testContext.queryandMatch({'isCollection': true}, validCollections);
      await testContext.queryandMatch({'isCollection': false}, media);
    }
  }

  Future<void> testParentID(
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

  Future<void> testType(
    TestContext testContext,
  ) async {
    {
      for (final type in types) {
        await testContext.queryandMatch(
            {'type': type}, allEntities.where((e) => e.type == type).toList());
      }
    }
  }

  Future<void> testIsDeleted(
    TestContext testContext,
  ) async {
    print('Items deleted: ${allEntities.where((e) => e.isDeleted).length}');
    await testContext.queryandMatch(
        {'isDeleted': true}, allEntities.where((e) => e.isDeleted).toList());
    await testContext.queryandMatch(
        {'isDeleted': false}, allEntities.where((e) => !e.isDeleted).toList());
  }

  Future<void> testLabel(
    TestContext testContext,
  ) async {
    {
      print(
          'Items without label: ${allEntities.where((e) => e.label == null).length}');
      print(
          'Items with label: ${allEntities.where((e) => e.label != null).length}');

      final labels = allEntities
          .map((e) => e.label)
          .where((e) => e != null)
          .cast<String>();

      await testContext.queryandMatch({'label': '__null__'},
          allEntities.where((e) => e.label == null).toList());
      await testContext.queryandMatch({'label': '__notnull__'},
          allEntities.where((e) => e.label != null).toList());

      for (final label in labels.shuffled().shuffled().take(15)) {
        await testContext.queryandMatch({'label': label},
            allEntities.where((e) => e.label == label).toList());
      }
      for (final label in startsWith) {
        await testContext.queryandMatch(
            {'labelStartsWith': label},
            allEntities
                .where((e) => e.label != null && e.label!.startsWith(label))
                .toList());
      }
      for (final label in contains) {
        await testContext.queryandMatch(
            {'labelContains': label},
            allEntities
                .where((e) => e.label != null && e.label!.contains(label))
                .toList());
      }
      for (final label in duplicates) {
        await testContext.queryandMatch({'label': label},
            allEntities.where((e) => e.label == label).toList());
      }
    }
  }

  Future<void> testDescription(
    TestContext testContext,
  ) async {
    {
      print(
          'Items without description: ${allEntities.where((e) => e.description == null).length}');
      print(
          'Items with description: ${allEntities.where((e) => e.description != null).length}');

      final description = allEntities
          .map((e) => e.description)
          .where((e) => e != null)
          .cast<String>();

      await testContext.queryandMatch({'description': '__null__'},
          allEntities.where((e) => e.description == null).toList());
      await testContext.queryandMatch({'description': '__notnull__'},
          allEntities.where((e) => e.description != null).toList());

      for (final description in description.shuffled().shuffled().take(15)) {
        await testContext.queryandMatch({'description': description},
            allEntities.where((e) => e.description == description).toList());
      }
      for (final description in startsWith) {
        await testContext.queryandMatch(
            {'descriptionStartsWith': description},
            allEntities
                .where((e) =>
                    e.description != null &&
                    e.description!.startsWith(description))
                .toList());
      }
      for (final description in contains) {
        await testContext.queryandMatch(
            {'descriptionContains': description},
            allEntities
                .where((e) =>
                    e.description != null &&
                    e.description!.contains(description))
                .toList());
      }
      for (final description in duplicates) {
        await testContext.queryandMatch({'description': description},
            allEntities.where((e) => e.description == description).toList());
      }
    }
  }

  Future<void> testMIMEType(
    TestContext testContext,
  ) async {
    {
      for (final mimeType in mimeTypes) {
        expect(mimeType, isIn(MimeTypes().all));
        await testContext.queryandMatch({'MIMEType': mimeType},
            allEntities.where((e) => e.mimeType == mimeType).toList());
      }
    }
  }

  Future<void> testExtension(
    TestContext testContext,
  ) async {
    {
      for (final extension in extensions) {
        await testContext.queryandMatch({'extension': extension},
            allEntities.where((e) => e.extension == extension).toList());
      }
    }
  }

  Future<void> dateTestCaseTemplate(TestContext testContext,
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
    for (final entry in dateTestCases.entries) {
      testCases[entry.key] = (TestContext testContext) => dateTestCaseTemplate(
          testContext,
          iters: entry.value.iters,
          iterMap: entry.value.iterMap,
          filter: entry.value.filter);
    }
    return testCases;
  }

  Map<String, DateTestCase> get dateTestCases => {
        'CreateDate': DateTestCase(
            iters: createDates.shuffled().take(8).toList(),
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
          iters: createDates.shuffled().take(8).toList(),
          iterMap: (currIter) {
            return {'CreateDateFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(currIter as DateTime) >= 0);
          },
        ),
        'CreateDateYYFrom': DateTestCase(
          iters: groupAndPickUpto8(createDates, 'year'),
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
          iters: groupAndPickUpto8(createDates, 'month'),
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
          iters: groupAndPickUpto8(createDates, 'day'),
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
          iters: createDates.shuffled().take(8).toList(),
          iterMap: (currIter) {
            return {'CreateDateTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.createDate != null &&
                (e.createDate!.compareTo(currIter as DateTime) <= 0);
          },
        ),
        'CreateDateYYTill': DateTestCase(
          iters: groupAndPickUpto8(createDates, 'year'),
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
          iters: groupAndPickUpto8(createDates, 'month'),
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
          iters: groupAndPickUpto8(createDates, 'day'),
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
            iters: addedDates.shuffled().take(8).toList(),
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
          iters: addedDates.shuffled().take(8).toList(),
          iterMap: (currIter) {
            return {'addedDateFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(currIter as DateTime) >= 0;
          },
        ),
        'addedDateYYFrom': DateTestCase(
          iters: groupAndPickUpto8(addedDates, 'year'),
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
          iters: groupAndPickUpto8(addedDates, 'month'),
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
          iters: groupAndPickUpto8(addedDates, 'day'),
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
          iters: addedDates.shuffled().take(8).toList(),
          iterMap: (currIter) {
            return {'addedDateTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.addedDate.compareTo(currIter as DateTime) <= 0;
          },
        ),
        'addedDateYYTill': DateTestCase(
          iters: groupAndPickUpto8(addedDates, 'year'),
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
          iters: groupAndPickUpto8(addedDates, 'month'),
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
          iters: groupAndPickUpto8(addedDates, 'day'),
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
            iters: updatedDates.shuffled().take(10).toList(),
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
          iters: updatedDates.shuffled().take(10).toList(),
          iterMap: (currIter) {
            return {'updatedDateFrom': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(currIter as DateTime) >= 0;
          },
        ),
        'updatedDateYYFrom': DateTestCase(
          iters: groupAndPickUpto8(updatedDates, 'year'),
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
          iters: groupAndPickUpto8(updatedDates, 'month'),
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
          iters: groupAndPickUpto8(updatedDates, 'day'),
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
          iters: updatedDates.shuffled().take(10).toList(),
          iterMap: (currIter) {
            return {'updatedDateTill': (currIter as DateTime).utcTimeStamp};
          },
          filter: (e, currIter) {
            return e.updatedDate.compareTo(currIter as DateTime) <= 0;
          },
        ),
        'updatedDateYYTill': DateTestCase(
          iters: groupAndPickUpto8(updatedDates, 'year'),
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
          iters: groupAndPickUpto8(updatedDates, 'month'),
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
          iters: groupAndPickUpto8(updatedDates, 'day'),
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

  List<String> get mimeTypes => allEntities
      .map((e) => e.mimeType)
      .where((e) => e != null)
      .cast<String>()
      .toSet()
      .toList()
    ..sort();

  List<String> get extensions => allEntities
      .map((e) => e.extension)
      .where((e) => e != null)
      .cast<String>()
      .toSet()
      .toList()
    ..sort();

  List<String> get types => allEntities
      .map((e) => e.type)
      .where((e) => e != null)
      .cast<String>()
      .toSet()
      .toList()
    ..sort();

  List<CLEntity> get allEntities => [...collections, ...media]
      .where((e) => e != null)
      .toList()
      .cast<CLEntity>();
  List<CLEntity> get validCollections =>
      collections.where((e) => e != null).toList().cast<CLEntity>();

  List<DateTime> groupAndPickUpto8(List<DateTime> currentDates, String by) {
    final grouped = <String, List<DateTime>>{};
    for (final date in currentDates) {
      final key = switch (by) {
        'year' => date.year.toString(),
        'month' => '${date.year}-${date.month.toString().padLeft(2, '0')}',
        'day' =>
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        _ => throw UnimplementedError()
      };

      grouped.putIfAbsent(key, () => []).add(date);
    }
    final selectedDates = <DateTime>[];
    for (final entry in grouped.entries) {
      final shuffled = entry.value.shuffled();

      // Take up to first 8 dates
      selectedDates.addAll(shuffled.take(8));
    }

    return selectedDates;
  }
}
