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

class UploadStateNotifier extends StateNotifier<UploadState?> {
  UploadStateNotifier(this.ref, super.state, {required this.downloadPath});
  final String? downloadPath;

  final Ref ref;

  bool get isScanReady {
    final status =
        downloadPath != null && state?.status == UploadStatus.success;

    return status;
  }

  Future<void> scanForFace() async {
    if (isScanReady) {
      if (state!.entity!.label == null) {
        throw Exception(
          "state can't be marked as success when no identity was provided",
        );
      }
      final faceIds = await ref
          .read(detectedFacesProvider.notifier)
          .scanImage(state!.entity!.label!, downloadPath: downloadPath!);

      ref.read(mediaListProvider.notifier).addFaces(state!.filePath, faceIds);
    }
  }
}
