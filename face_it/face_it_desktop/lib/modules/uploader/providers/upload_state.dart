import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_services/colan_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_state.dart';
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
  UploadStateNotifier(this.ref, super._state, {required this.downloadPath});
  final String? downloadPath;
  final Ref ref;

  @override
  String get logPrefix => 'UploadStateNotifier';
}
