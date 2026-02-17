import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

extension UtilExtensionOnFile on File {
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }

  Future<String> get checksum async {
    try {
      final stream = openRead();
      final hash = await md5.bind(stream).first;

      // NOTE: You might not need to convert it to base64
      return hash.toString();
    } catch (exception) {
      throw Exception('unable to determine md5');
    }
  }

  static String getRandomString(int length) {
    const characters = '0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  static String getAvailableFileName(String fileName) {
    var file = File(fileName);
    if (!file.existsSync()) {
      return fileName;
    }

    final dir = file.parent.path;
    final baseName = file.uri.pathSegments.last.split('.').first;
    final extension = file.uri.pathSegments.last.split('.').length > 1
        ? '.${file.uri.pathSegments.last.split('.').last}'
        : '';

    while (file.existsSync()) {
      final randomString = getRandomString(5); // Adjust the length as needed
      final newFileName = '$dir/${baseName}_$randomString$extension';
      file = File(newFileName);
    }

    return file.path;
  }

  File copyTo(Directory directory) {
    final targetPath = p.join(directory.path, p.basename(path));
    if (targetPath == path) {
      return this;
    }
    final updatedTarget = getAvailableFileName(targetPath);
    return copySync(updatedTarget);
  }
}
