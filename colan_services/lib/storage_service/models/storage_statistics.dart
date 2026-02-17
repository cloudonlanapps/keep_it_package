import 'dart:async';
import 'dart:io';

import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnNum;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

@immutable
class StorageStatistics {
  const StorageStatistics({
    required this.count,
    required this.size,
  });

  final int count;
  final int size;

  StorageStatistics copyWith({
    int? count,
    int? size,
  }) {
    return StorageStatistics(
      count: count ?? this.count,
      size: size ?? this.size,
    );
  }

  @override
  String toString() => 'StorageStatistics(count: $count, size: $size)';

  @override
  bool operator ==(covariant StorageStatistics other) {
    if (identical(this, other)) return true;

    return other.count == count && other.size == size;
  }

  @override
  int get hashCode => count.hashCode ^ size.hashCode;

  static Future<StorageStatistics> storageUse(Directory dir) async {
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

    return StorageStatistics(count: fileCount, size: totalSize);
  }

  String get statistics {
    //return '$size ($count files)';
    return '${size.toHumanReadableFileSize()} [$size Bytes] ($count files)';
  }
}

final StreamProviderFamily<StorageStatistics, Directory>
storageStatisticsProvider = StreamProvider.family<StorageStatistics, Directory>(
  (ref, dir) async* {
    final streamController = StreamController<StorageStatistics>();
    final watcher = DirectoryWatcher(
      p.absolute(dir.path),
      pollingDelay: const Duration(seconds: 1),
    );

    streamController.add(await StorageStatistics.storageUse(dir));
    watcher.events.listen((watchEvent) async {
      streamController.add(await StorageStatistics.storageUse(dir));
    });

    yield* streamController.stream;
  },
);
