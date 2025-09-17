import 'dart:io';

import 'package:face_it_desktop/views/browser/media_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/main_content_type.dart';
import '../../providers/a_files.dart';
import '../../providers/b_candidate.dart';
import '../../providers/main_content_type.dart';

class ImageTile extends ConsumerWidget {
  const ImageTile({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Image.file(
        File(file.path), // Replace with your image URL
        width: 64,
        height: 64,
      ),
      title: Text(file.name, overflow: TextOverflow.ellipsis, maxLines: 2),
      subtitle: FileStatus(file: file),
      trailing: MediaPopover(file: file),
      onTap: () {
        ref
            .read(sessionCandidateProvider(file).notifier)
            .recognize(minimumDelay: null);
        ref.read(activeMainContentTypeProvider.notifier).state =
            MainContentType.images;
        ref.read(sessionFilesProvider.notifier).setActiveFile(file.path);
      },
    );
  }
}

class FileStatus extends ConsumerWidget {
  const FileStatus({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref
        .watch(sessionCandidateProvider(file))
        .whenOrNull(data: (data) => data);
    final fileStatus = candidate?.statusString;
    return candidate == null
        ? const SizedBox.shrink()
        : Text(
            candidate.uploadProgress ?? fileStatus!,
            style: ShadTheme.of(context).textTheme.muted,
          );
  }
}
