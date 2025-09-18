import 'package:face_it_desktop/content_manager.dart/providers/candidates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/uploader.dart';

class UploadStatusView extends ConsumerWidget {
  const UploadStatusView({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(
      candidatesProvider.select(
        (candidates) => candidates.itemByPath(file.path),
      ),
    );
    final uploader = ref
        .watch(uploaderProvider)
        .whenOrNull(data: (data) => data);
    final statusString =
        uploader?.files[file.path]?.statusString ?? 'Not uploaded';
    final error = uploader?.files[file.path]?.error;
    final msgWidget = Text(
      statusString,
      style: ShadTheme.of(context).textTheme.muted,
    );
    return candidate == null
        ? const SizedBox.shrink()
        : error == null
        ? msgWidget
        : Tooltip(message: error, child: msgWidget);
  }
}
