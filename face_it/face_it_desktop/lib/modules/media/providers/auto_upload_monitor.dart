import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../uploader/providers/uploader.dart';
import 'candidates.dart';

class AutoUploadMonitor with CLLogger {
  // Call this function only inside a build
  void watch(WidgetRef ref) {
    ref
      ..listen(serverPreferenceProvider.select((e) => e.autoUpload), (
        prev,
        autoUpload,
      ) {
        if (autoUpload && prev != autoUpload) {
          // upload all files from the media
          final files = ref.read(
            mediaListProvider.select(
              (e) => e.mediaList.map((e) => e.file.path),
            ),
          );
          log(
            'listening serverPreferenceProvider: autoUpload $autoUpload ${files.length} files',
          );
          log('listening serverPreferenceProvider: trigger upload');

          ref.read(uploaderProvider.notifier).uploadMultiple(files);
        }
      })
      ..listen(mediaListProvider, (prev, curr) {
        final autoUpload = ref.read(
          serverPreferenceProvider.select((e) => e.autoUpload),
        );
        log(
          'listening mediaListProvider: autoUpload: $autoUpload, ${curr.mediaList.length} files',
        );
        if (autoUpload && curr.mediaList.isNotEmpty) {
          log('listening serverPreferenceProvider: trigger upload');

          ref
              .read(uploaderProvider.notifier)
              .uploadMultiple(curr.mediaList.map((e) => e.file.path));
        }
      });
  }

  @override
  String get logPrefix => 'AutoUploadMonitor';
}

class AutoFaceRecgMonitor with CLLogger {
  @override
  String get logPrefix => 'AutoFaceRecMonitor';

  void watch(WidgetRef ref) {
    ref
      ..listen(serverPreferenceProvider.select((e) => e.autoFaceRecg), (
        prev,
        autoFaceRecg,
      ) {
        if (prev != autoFaceRecg && autoFaceRecg) {
          // Trigger here
        }
      })
      ..listen(uploaderProvider, (prev, curr) {
        final autoFaceRecg = ref.read(
          serverPreferenceProvider.select((e) => e.autoFaceRecg),
        );
        if (autoFaceRecg) {
          // Trigger here
        }
      });
  }
}
