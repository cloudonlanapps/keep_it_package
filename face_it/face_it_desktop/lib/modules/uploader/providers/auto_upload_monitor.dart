import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_services/cl_server_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media/providers/candidates.dart';
import 'uploader.dart';

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
            unawaited(
              ref
                  .read(uploaderProvider.notifier)
                  .uploadMultiple(filesNotYetUploaded.map((e) => e.path)),
            );
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
            unawaited(
              ref.read(uploaderProvider.notifier).uploadMultiple(filesToUpload),
            );
          }
        }
      });
  }

  @override
  String get logPrefix => 'AutoUploadMonitor';
}
