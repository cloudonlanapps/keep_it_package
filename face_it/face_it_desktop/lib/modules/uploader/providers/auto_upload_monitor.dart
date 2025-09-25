import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'uploader.dart';
import '../../media/providers/candidates.dart';

///       Algo
/// When autoUpload state is changed to on
///   find the files not yet uploaded and upload them.
/// When mediaListChanged,
///   find newly added files and reconfirm that the file is not yet uploaded
///   then upload
class AutoUploadMonitor with CLLogger {
  void watch(WidgetRef ref) {
    ref
      ..listen(serverPreferenceProvider.select((e) => e.autoUpload), (
        prev,
        autoUpload,
      ) {
        if (autoUpload && prev != autoUpload) {
          final files = ref.read(
            mediaListProvider.select((e) => e.mediaList.map((e) => e)),
          );

          final filesInUploader = ref.read(uploaderProvider).files.keys;
          final filesNotYetUploaded = files.where(
            (e) => !filesInUploader.contains(e.path),
          );

          if (filesNotYetUploaded.isNotEmpty) {
            log('adding ${filesNotYetUploaded.length} into uploader');
            ref
                .read(uploaderProvider.notifier)
                .uploadMultiple(filesNotYetUploaded.map((e) => e.path));
          }
        }
      })
      ..listen(mediaListProvider.select((e) => e.mediaList), (prev, curr) {
        final autoUpload = ref.read(
          serverPreferenceProvider.select((e) => e.autoUpload),
        );
        log('Media list changed');
        log(
          'prev: ${prev == null ? "" : prev.length} (${prev?.map((e) => e.name)})',
        );
        log('curr: ${curr.length} (${curr.map((e) => e.name)})');

        if (autoUpload) {
          final previousPaths = prev?.map((e) => e.path).toSet() ?? {};

          final newlyAddedPaths = curr
              .where((e) => !previousPaths.contains(e.path))
              .map((e) => e.path);

          final filesInUploader = ref.read(uploaderProvider).files.keys.toSet();

          final filesToUpload = newlyAddedPaths.where(
            (path) => !filesInUploader.contains(path),
          );

          if (filesToUpload.isNotEmpty) {
            log('Adding ${filesToUpload.length} files for upload.');
            ref.read(uploaderProvider.notifier).uploadMultiple(filesToUpload);
          }
        }
      })
      ..listen(uploaderProvider, (prev, curr) {
        final autoFaceRecg = ref.read(
          serverPreferenceProvider.select((e) => e.autoFaceRecg),
        );
        if (autoFaceRecg) {
          ref.read(uploaderProvider.notifier).faceRecgAllEligible();
        }
      })
      ..listen(serverPreferenceProvider.select((e) => e.autoFaceRecg), (
        prev,
        autoFaceRecg,
      ) {
        if (autoFaceRecg && prev != autoFaceRecg) {
          ref.read(uploaderProvider.notifier).faceRecgAllEligible();
        }
      });
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
