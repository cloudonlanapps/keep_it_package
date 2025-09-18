import 'dart:io';

import 'package:face_it_desktop/views/browser/media_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../content_manager.dart/providers/candidates.dart';
import '../../models/main_content_type.dart';
import '../../providers/main_content_type.dart';

class ImageTile extends ConsumerWidget {
  const ImageTile({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Image.file(File(file.path), width: 64, height: 64),
      title: Text(file.name, overflow: TextOverflow.ellipsis, maxLines: 2),
      subtitle: FileStatus(file: file),
      trailing: MediaPopover(file: file),
      onTap: () {
        ref.read(activeMainContentTypeProvider.notifier).state =
            MainContentType.images;
        ref.read(candidatesProvider.notifier).setActiveFile(file.path);
      },
    );
  }
}

class FileStatus extends ConsumerWidget {
  const FileStatus({required this.file, super.key});
  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(
      candidatesProvider.select(
        (candidates) => candidates.itemByPath(file.path),
      ),
    );
    const fileStatus = 'no activity';
    return candidate == null
        ? const SizedBox.shrink()
        : Text(fileStatus, style: ShadTheme.of(context).textTheme.muted);
  }
}
