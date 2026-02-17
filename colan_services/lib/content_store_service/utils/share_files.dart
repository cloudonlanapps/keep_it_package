import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareManager {
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

  static Future<bool> onShareFiles(
    BuildContext ctx,
    List<String> files, {
    Rect? sharePositionOrigin,
  }) async {
    final xFiles = files.map(XFile.new).toList();
    final randString = getRandomString(5);
    final shareResult = await SharePlus.instance.share(
      ShareParams(
        files: xFiles,
        subject: 'from KeepIt',
        sharePositionOrigin: sharePositionOrigin,
        fileNameOverrides: xFiles.mapIndexed((i, e) {
          return 'keepIt_${randString}_$i';
        }).toList(),
      ),
    );
    return switch (shareResult.status) {
      ShareResultStatus.dismissed => false,
      ShareResultStatus.unavailable => false,
      ShareResultStatus.success => true,
    };
  }
}
