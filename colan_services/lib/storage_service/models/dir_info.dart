import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_statistics.dart';

@immutable
class DirInfo {
  const DirInfo({
    required this.name,
    required this.directory,
    required this.statsAsync,
    this.onTapAction,
  });
  final String name;
  final String directory;
  final VoidCallback? onTapAction;
  final AsyncValue<StorageStatistics> statsAsync;
}
