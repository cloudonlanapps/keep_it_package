import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'text_ext_on_cl_server.dart';
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

  Future<void> dispose() async {
    await server.cleanupEntity(entities);
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
}
