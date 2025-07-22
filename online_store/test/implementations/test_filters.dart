import 'dart:math';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:online_store/src/models/server_enitity_query.dart';

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
    for (var i = 0; i < 10; i++) {
      final label1 = random2.nextString(prefix: 'test_');
      final entity1 = await testContext.server.validCreate(testContext,
          isCollection: () => true, label: () => label1);
      testContext.validate(entity1,
          id: isNotNull, label: equals(label1), description: isNull);
      collections.add(entity1);
    }
    final entitites = <CLEntity>[];
    // add jpg images with CreateDate
    for (var i = 0; i < 300; i++) {
      final parentId = collections[random.nextInt(collections.length)]?.id;
      final randomSeconds = random.nextInt(difference);
      final randomDate = start.add(Duration(seconds: randomSeconds));

      final imageFile = await testContext.createImageWithDateTime(randomDate);
      final entity1 = await testContext.server.validCreate(testContext,
          fileName: imageFile,
          parentId: parentId == null ? null : () => parentId);

      testContext.validate(entity1,
          id: isNotNull, md5: isNotNull, createDate: isNotNull);
      expect(entity1.createDate, randomDate,
          reason:
              "${entity1.id} createDate didn't match: set: $randomDate, got: ${entity1.createDate}");
      entitites.add(entity1);
    }
    // add few jpg images without any createDate
    for (var i = 0; i < 40; i++) {
      final parentId = collections[random.nextInt(collections.length)]?.id;
      final imageFile = testContext.createImage();
      final entity1 = await testContext.server.validCreate(testContext,
          fileName: imageFile,
          parentId: parentId == null ? null : () => parentId);

      testContext.validate(
        entity1,
        id: isNotNull,
        md5: isNotNull,
      );

      entitites.add(entity1);
    }
    return TestFilters(collections: collections, media: entitites);
  }

  Future<void> testF1(TestContext testContext) async {
    for (final collection in collections) {
      final queryString = ServerCLEntityQuery()
          .getQueryString(map: {'parentId': collection?.id});

      final items = (await (await testContext.server
              .getAll(queryString: queryString))
          .when(
              validResponse: (items) async => items,
              errorResponse: (e, {st}) async {
                fail('getAll Failed');
              }))
        ..sort(sorter);
      final expected = media.where((e) => e.parentId == collection?.id).toList()
        ..sort(sorter);

      final listEquals = const ListEquality<CLEntity>().equals;

      expect(listEquals(items, expected), isTrue);
    }
  }

  int sorter(CLEntity a, CLEntity b) {
    if (a.id == null && b.id == null) return 0;
    if (a.id == null) return 1; // a goes after b
    if (b.id == null) return -1; // b goes after a
    return a.id!.compareTo(b.id!);
  }
}
