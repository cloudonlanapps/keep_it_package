import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:test/test.dart';
import '../framework/framework.dart';

class TestDateTimeOriginal {
  static Future<void> testDT1(TestContext testContext) async {
    final random = Random();
    final now = DateTime(2024, 12, 31, 23, 59, 59);
    final start = DateTime(2020);
    final difference = now.difference(start).inSeconds;

    for (var i = 0; i < 1; i++) {
      // Generate random date between start and now

      final randomSeconds = random.nextInt(difference);
      final randomDate = start.add(Duration(seconds: randomSeconds));

      // Create image file
      final imageFile = testContext.createImage();

      // Write DateTimeOriginal tag
      await addDateTimeOriginal(imageFile, randomDate);

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
        expect(parsedDate.isAtSameMomentAs(randomDate), isTrue,
            reason: 'Date mismatch on image $i');
      } else {
        fail('DateTimeOriginal is not found in the image');
      }
      final entity1 = await testContext.server
          .validCreate(testContext, fileName: imageFile);

      testContext.validate(
        entity1,
        id: isNotNull,
        md5: isNotNull, /* createDate: isNotNull */
      );
    }
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

    if (result.exitCode == 0) {
      print('✅ DateTimeOriginal set to: $exifDate');
    } else {
      throw Exception('❌ Failed to add DateTimeOriginal: ${result.stderr}');
    }
  }
}
