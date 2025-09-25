import 'package:face_it_desktop/modules/uploader/models/upload_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/uploader.dart';

class ProgressViewUploadMedia extends ConsumerWidget {
  const ProgressViewUploadMedia({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploader = ref.watch(uploaderProvider);
    final fileState = uploader.files[file.path];
    final uploadStatus = fileState.uploadStatus;
    final error = uploader.files[file.path]?.error;
    final msgWidget = SizedBox(
      height: 8,
      child: switch (uploadStatus) {
        UploadStatus.notQueued => Container(
          color: ShadTheme.of(context).colorScheme.muted,
        ),
        UploadStatus.ignored => Container(color: Colors.orange),
        UploadStatus.pending => LinearProgressIndicator(
          color: Colors.yellow,
          backgroundColor: ShadTheme.of(context).colorScheme.muted,
        ),
        UploadStatus.complete => Container(color: Colors.green),
        UploadStatus.running => LinearProgressIndicator(
          value: fileState!.uploadProgress!.progress,
        ),
        UploadStatus.failed => Container(color: Colors.red),
      },
    );

    return error == null
        ? msgWidget
        : Tooltip(message: error, child: msgWidget);
  }
}
