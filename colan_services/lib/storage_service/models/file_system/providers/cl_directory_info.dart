import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watcher/watcher.dart';

import '../models/cl_directory.dart';
import '../models/cl_directory_info.dart';

extension CLDirectoryInfoExt on CLDirectory {
  StreamProvider<CLDirectoryInfo> get infoStream => directoryInfoProvider(this);
}

final StreamProviderFamily<CLDirectoryInfo, CLDirectory> directoryInfoProvider =
    StreamProvider.family<CLDirectoryInfo, CLDirectory>((ref, dir) async* {
  final streamController = StreamController<CLDirectoryInfo>();
  final watcher = DirectoryWatcher(
    dir.pathString,
    pollingDelay: const Duration(seconds: 1),
  );

  streamController.add(await CLDirectoryInfo.storageUse(dir.path));
  watcher.events.listen((watchEvent) async {
    streamController.add(await CLDirectoryInfo.storageUse(dir.path));
  });

  yield* streamController.stream;
});
