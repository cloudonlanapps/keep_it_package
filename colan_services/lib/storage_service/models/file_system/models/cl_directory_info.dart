import 'dart:io';

import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnNum;
import 'package:flutter/foundation.dart';

@immutable
class CLDirectoryInfo {
  const CLDirectoryInfo({
    required this.count,
    required this.size,
  });

  final int count;
  final int size;

  CLDirectoryInfo copyWith({
    int? count,
    int? size,
  }) {
    return CLDirectoryInfo(
      count: count ?? this.count,
      size: size ?? this.size,
    );
  }

  @override
  String toString() => 'CLDirectoryInfo(count: $count, size: $size)';

  @override
  bool operator ==(covariant CLDirectoryInfo other) {
    if (identical(this, other)) return true;

    return other.count == count && other.size == size;
  }

  @override
  int get hashCode => count.hashCode ^ size.hashCode;

  static Future<CLDirectoryInfo> storageUse(Directory dir) async {
    var fileCount = 0;
    var totalSize = 0;

    if (dir.existsSync()) {
      dir.listSync(recursive: true, followLinks: false).forEach((entity) {
        if (entity is File) {
          fileCount++;
          totalSize += entity.lengthSync();
        }
      });
    }

    return CLDirectoryInfo(count: fileCount, size: totalSize);
  }

  String get statistics {
    //return '$size ($count files)';
    if (count == 0) return 'Empty';
    return '${size.toHumanReadableFileSize()} [$size Bytes] ($count files)';
  }

  CLDirectoryInfo operator +(CLDirectoryInfo other) {
    return CLDirectoryInfo(count: count + other.count, size: size + other.size);
  }
}
