/* import 'dart:math';

import 'package:test/test.dart';
import '../framework/framework.dart';

class TestDateTimeOriginal {
  static Future<void> testDT1(TestContext testContext) async {
    final random = Random();
    final now = DateTime(2024, 12, 31, 23, 59, 59);
    final start = DateTime(2020);
    final difference = now.difference(start).inSeconds;

    final randomSeconds = random.nextInt(difference);
    final randomDate = start.add(Duration(seconds: randomSeconds));

    final imageFile = await testContext.createImageWithDateTime(randomDate);
    final entity1 =
        await testContext.server.validCreate(testContext, fileName: imageFile);

    testContext.validate(entity1,
        id: isNotNull, md5: isNotNull, createDate: isNotNull);
    expect(entity1.createDate, randomDate,
        reason:
            "createDate didn't match: set: $randomDate, got: ${entity1.createDate}");
  }
}
 */
