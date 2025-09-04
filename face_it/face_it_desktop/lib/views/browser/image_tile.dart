import 'dart:io';
import 'package:face_it_desktop/models/session_candidate.dart';
import 'package:face_it_desktop/views/browser/media_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/a_files.dart';

class ImageTile extends ConsumerWidget {
  const ImageTile({required this.media, super.key});
  final SessionCandidate media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Image.file(
        File(media.path), // Replace with your image URL
        width: 64,
        height: 64,
      ),
      title: Text(
        media.label,
        style: ShadTheme.of(context).textTheme.small,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: MediaPopover(media: media),
      onTap: () {
        ref.read(sessionFilesProvider.notifier).setActiveFile(media.path);
      },
    );
  }
}
