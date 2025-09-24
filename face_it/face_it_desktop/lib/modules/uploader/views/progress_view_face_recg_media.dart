import 'package:face_it_desktop/modules/uploader/models/upload_state.dart';
import 'package:face_it_desktop/modules/uploader/providers/uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProgressViewFaceRecgMedia extends ConsumerWidget {
  const ProgressViewFaceRecgMedia({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploader = ref.watch(uploaderProvider);
    final faceRecgStatus = uploader.files[file.path]?.faceRecgStatus;

    final msgWidget = SizedBox(
      height: 8,
      child: switch (faceRecgStatus) {
        null => Container(color: ShadTheme.of(context).colorScheme.muted),

        ActivityStatus.premature => Container(
          color: ShadTheme.of(context).colorScheme.muted,
        ),

        ActivityStatus.pending ||
        ActivityStatus.processingNow => LinearProgressIndicator(
          color: Colors.yellow,
          backgroundColor: ShadTheme.of(context).colorScheme.muted,
        ),

        ActivityStatus.success => Container(color: Colors.green),

        ActivityStatus.error => Container(color: Colors.red),

        ActivityStatus.ignore => Container(color: Colors.orange),
      },
    );

    return msgWidget;
  }
}
