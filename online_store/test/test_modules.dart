import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:path/path.dart';
import 'package:test/test.dart';

import 'utils.dart';

class TestArtifacts {
  TestArtifacts({required this.tempDir});

  final Directory tempDir;
  final List<String> fileArtifacts = [];

  Future<void> dispose() async {
    for (final file in fileArtifacts) {
      await File(file).deleteIfExists();
    }
  }

  File generateFile(Directory tempDir) {
    final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
    generateRandomPatternImage(filename);
    final file = File(filename);
    if (!file.existsSync()) {
      fail('Unable to generate image file');
    }
    return file;
  }

  String createImage() {
    final String? fileName0;

    fileName0 = generateFile(tempDir).path;
    fileArtifacts.add(fileName0);
    return fileName0;
  }
}
