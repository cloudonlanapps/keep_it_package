import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/file_system/models/cl_directories.dart';

final deviceDirectoriesProvider = FutureProvider<CLDirectories>((ref) async {
  final directories = CLDirectories(
    persistent: await getApplicationSupportDirectory(),
    temporary: await getApplicationCacheDirectory(),
    systemTemp: Directory.systemTemp,
  );
  return directories;
});
