// ignore_for_file: avoid_print, print required for testing

import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:online_store/src/models/server_enitity_query.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../implementations/test_filters_loopback.dart';
import 'test_ext_on_cl_server.dart';
import 'utils.dart';

class TestContext {
  TestContext({required this.tempDir, required this.server}) {
    Directory(tempDir).createSync(recursive: true);
    //print('Artifacts will be saved into the directory : $tempDir');
  }

  final String tempDir;
  final CLServer server;
  final List<String> fileArtifacts = [];
  final Set<int> entities = {};

  Future<void> dispose({bool serverCleanup = true}) async {
    if (serverCleanup) {
      await server.cleanupEntity(entities);
    }
    Directory(tempDir).deleteSync(recursive: true);
    //print('Artifacts directory $tempDir removed');
  }

  String generateFile(Directory tempDir) {
    final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
    generateRandomPatternImage(filename);
    final file = File(filename);
    if (!file.existsSync()) {
      fail('Unable to generate image file');
    }
    return file.path;
  }

  String createImage() {
    final String? fileName0;

    fileName0 = generateFile(Directory(tempDir));
    fileArtifacts.add(fileName0);
    return fileName0;
  }

  Future<String> createImageWithDateTime(DateTime dateTime) async {
    // Create image file
    final imageFile = createImage();

    // Write DateTimeOriginal tag
    await addDateTimeOriginal(imageFile, dateTime);

    // Read back using image package

    final decodedImage = await img.decodeImageFile(imageFile);
    final exifDateStr = decodedImage?.exif.exifIfd.data[36867];
    if (exifDateStr != null) {
      // Convert back to DateTime for comparison
      // exifDateStr format is "yyyy:MM:dd HH:mm:ss"
      final parsedDate = DateTime.parse(exifDateStr
          .toString()
          .replaceFirst(':', '-')
          .replaceFirst(':', '-', 5));

      // Compare ignoring milliseconds since EXIF has only seconds precision
      expect(parsedDate.isAtSameMomentAs(dateTime), isTrue,
          reason: 'Date mismatch on image');
    } else {
      fail('DateTimeOriginal is not found in the image');
    }
    return imageFile;
  }

  static Future<void> addDateTimeOriginal(
      String imagePath, DateTime dateTime) async {
    final exifFormat = DateFormat('yyyy:MM:dd HH:mm:ss');
    final exifDate = exifFormat.format(dateTime);

    final result = await Process.run(
      'exiftool',
      [
        '-overwrite_original', // avoid creating backup files
        '-DateTimeOriginal=$exifDate', // set the tag
        imagePath,
      ],
    );
    expect(result.exitCode, 0,
        reason: 'Failed to add DateTimeOriginal: ${result.stderr}');
  }

  void validate(CLEntity entity,
      {Matcher? id,
      Matcher? isCollection,
      Matcher? addedDate,
      Matcher? updatedDate,
      Matcher? isDeleted,
      Matcher? label,
      Matcher? description,
      Matcher? parentId,
      Matcher? md5,
      Matcher? fileSize,
      Matcher? mimeType,
      Matcher? type,
      Matcher? extension,
      Matcher? createDate,
      Matcher? height,
      Matcher? width,
      Matcher? duration,
      Matcher? isHidden,
      Matcher? pin,
      String prefix = ''}) {
    final matchers = [
      (id, entity.id, '${prefix}mismatch in id'),
      (isCollection, entity.isCollection, '${prefix}mismatch in isCollection'),
      (addedDate, entity.addedDate, '${prefix}mismatch in addedDate'),
      (updatedDate, entity.updatedDate, '${prefix}mismatch in updatedDate'),
      (isDeleted, entity.isDeleted, '${prefix}mismatch in isDeleted'),
      (label, entity.label, '${prefix}mismatch in label'),
      (description, entity.description, '${prefix}mismatch in description'),
      (parentId, entity.parentId, '${prefix}mismatch in parentId'),
      (md5, entity.md5, '${prefix}mismatch in md5'),
      (fileSize, entity.fileSize, '${prefix}mismatch in fileSize'),
      (mimeType, entity.mimeType, '${prefix}mismatch in mimeType'),
      (type, entity.type, '${prefix}mismatch in type'),
      (extension, entity.extension, '${prefix}mismatch in extension'),
      (createDate, entity.createDate, '${prefix}mismatch in createDate'),
      (height, entity.height, '${prefix}mismatch in height'),
      (width, entity.width, '${prefix}mismatch in width'),
      (duration, entity.duration, '${prefix}mismatch in duration'),
      (isHidden, entity.isHidden, '${prefix}mismatch in isHidden'),
      (pin, entity.pin, '${prefix}mismatch in pin'),
    ];
    for (final (expected, actual, message) in matchers) {
      if (expected != null) {
        expect(actual, expected, reason: message);
      }
    }
  }

  int sorter(CLEntity a, CLEntity b) {
    if (a.id == null && b.id == null) return 0;
    if (a.id == null) return 1; // a goes after b
    if (b.id == null) return -1; // b goes after a
    return a.id!.compareTo(b.id!);
  }

  Future<void> queryandMatch(
      Map<String, dynamic>? queryMap, List<CLEntity> expected) async {
    await TestFiltersLoopback.testLBRandomMap(this, queryMap ?? {});
    final queryString = ServerCLEntityQuery().getQueryString(map: queryMap);
    final items = (await (await server.getAll(queryString: queryString)).when(
        validResponse: (items) async => items,
        errorResponse: (e, {st}) async {
          fail('getAll Failed');
        }))
      ..sort(sorter);

    matchEntityList(items, expected..sort(sorter));
  }

  void matchEntityList(List<CLEntity> actual, List<CLEntity> expected) {
    expect(actual.length, expected.length,
        reason: 'expected ${expected.length}, received ${actual.length}\n'
            'expected:${expected.map((e) => e.id).toList()}\n'
            'received: ${actual.map((e) => e.id).toList()}');

    final listEquals = const ListEquality<CLEntity>().equals;
    if (!listEquals(actual, expected)) {
      for (final (i, item) in actual.indexed) {
        if (expected[i] != item) {
          print('expected: ${expected[i]}\nactual: $item\n\n}');
        }
      }
    }
    expect(listEquals(actual, expected), true,
        reason: "Item contents don't match");
  }
}
