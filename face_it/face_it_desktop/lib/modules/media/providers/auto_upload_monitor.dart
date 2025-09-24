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
      ..listen(mediaListProvider.select((e) => e.mediaList), (prev, curr) {
        final autoUpload = ref.read(
          serverPreferenceProvider.select((e) => e.autoUpload),
        );
        log(
          'listening mediaListProvider: autoUpload: $autoUpload, ${curr.length} files',
        );

        if (autoUpload && curr.isNotEmpty) {
          log('listening serverPreferenceProvider: trigger upload');

          ref
              .read(uploaderProvider.notifier)
              .uploadMultiple(curr.map((e) => e.file.path));
        }
      })
    /* ..listen(uploaderProvider, (prev, curr) {
        final autoFaceRecg = ref.read(
          serverPreferenceProvider.select((e) => e.autoFaceRecg),
        );
        if (autoFaceRecg) {
          ref.read(uploaderProvider.notifier).faceRecgAllEligible();
        }
      }) */
    ;
  }

  @override
  String get logPrefix => 'AutoUploadMonitor';
}

/**
 * 
 ..listen(serverPreferenceProvider.select((e) => e.autoUpload), (
        prev,
        curr,
      ) {
        final url = ref.read(uploadURLProvider);
        if (prev != curr && curr && url != null) {
          ref.read(uploaderProvider.notifier).retryNew(url);
        }
      });
 */
