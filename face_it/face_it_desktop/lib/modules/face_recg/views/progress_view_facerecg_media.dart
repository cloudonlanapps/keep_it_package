import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/image_face_mapper.dart';
import '../providers/face_recg.dart';

class ProgressViewFaceRecgMedia extends ConsumerWidget {
  const ProgressViewFaceRecgMedia({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappers = ref.watch(faceRecgProvider);
    final faceRecgStatus = mappers.mappers
        .where((e) => e.image == file.path)
        .firstOrNull
        ?.status;

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
        ActivityStatus.ready => Container(color: Colors.orange),
      },
    );

    return msgWidget;
  }
}
