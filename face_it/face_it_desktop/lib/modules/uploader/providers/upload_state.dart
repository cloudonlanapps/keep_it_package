import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media/providers/candidates.dart';
import '../models/upload_state.dart';
import '../models/upload_status.dart';
import 'uploader.dart';

final uploadStateProvider =
    StateNotifierProviderFamily<UploadStateNotifier, UploadState?, String>((
      ref,
      path,
    ) {
      final tempDirectory = ref
          .watch(deviceDirectoriesProvider)
          .whenOrNull(data: (data) => data.temporary.path);
      final uploaderState = ref.watch(
        uploaderProvider.select((e) => e.files[path]),
      );
      return UploadStateNotifier(
        ref,
        uploaderState,
        downloadPath: tempDirectory,
      );
    });

class UploadStateNotifier extends StateNotifier<UploadState?> with CLLogger {
  UploadStateNotifier(this.ref, super.state, {required this.downloadPath});
  final String? downloadPath;
  final Ref ref;

  @override
  String get logPrefix => 'UploadStateNotifier';

  bool get isScanReady {
    final status =
        downloadPath != null && state?.status == UploadStatus.success;

    return status;
  }

  Future<void> scanForFace({bool forced = false}) async {
    // File is not yet uplaoded, return quitely
    if (state == null) return;
    try {
      if (isScanReady) {
        if (state!.entity!.label == null) {
          throw Exception(
            "state can't be marked as success when no identity was provided",
          );
        }
        final faceIds = await ref
            .read(detectedFacesProvider.notifier)
            .scanImage(
              state!.entity!.label!,
              downloadPath: downloadPath!,
              isStillRequired: forced
                  ? null
                  : () {
                      /// IF we had face already, even if it is empty
                      /// we should skip
                      final faces = ref.read(
                        mediaListProvider.select(
                          (e) => e.getFaces(state!.filePath),
                        ),
                      );
                      if (faces != null) {
                        log(
                          'Cancel requested as faces are already available: faces: $faces',
                        );
                      }
                      return faces == null;
                    },
            );

        ref.read(mediaListProvider.notifier).addFaces(state!.filePath, faceIds);
      }
    } catch (e) {
      log('face scan aborted for ${state!.filePath}');
    }
  }
}
