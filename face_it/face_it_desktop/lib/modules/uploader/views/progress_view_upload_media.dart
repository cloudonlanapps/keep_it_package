import 'package:background_downloader/background_downloader.dart';
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
    final uploadProgress = uploader.files[file.path]?.uploadProgress;
    final error = uploader.files[file.path]?.error;
    final msgWidget = SizedBox(
      height: 8,
      child: switch (uploadProgress?.status) {
        null => Container(color: ShadTheme.of(context).colorScheme.muted),

        TaskStatus.enqueued => LinearProgressIndicator(
          color: Colors.yellow,
          backgroundColor: ShadTheme.of(context).colorScheme.muted,
        ),

        TaskStatus.waitingToRetry || TaskStatus.running || TaskStatus.paused =>
          LinearProgressIndicator(value: uploadProgress!.progress),

        TaskStatus.complete => Container(color: Colors.green),

        TaskStatus.notFound => Container(
          color: ShadTheme.of(context).colorScheme.muted,
        ),

        TaskStatus.failed ||
        TaskStatus.canceled => Container(color: Colors.red),
      },
    );

    return error == null
        ? msgWidget
        : Tooltip(message: error, child: msgWidget);
  }
}
