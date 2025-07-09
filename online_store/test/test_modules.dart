// ignore_for_file: avoid_print

import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'text_ext_on_cl_server.dart';
import 'utils.dart';

class TestArtifacts {
  TestArtifacts({required this.tempDir, required this.server}) {
    Directory(tempDir).createSync(recursive: true);
    print('Artifacts will be saved into the directory : $tempDir');
  }

  final String tempDir;
  final CLServer server;
  final List<String> fileArtifacts = [];
  final List<int> entities = [];

  Future<void> dispose() async {
    await server.cleanupEntity(entities);
    Directory(tempDir).deleteSync(recursive: true);
    print('Artifacts directory $tempDir removed');
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
}
