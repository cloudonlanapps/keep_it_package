import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../face_recg/views/progress_view_facerecg_media.dart';
import '../../uploader/views/progress_view_upload_media.dart';
import 'media.dart';
import 'media_popover_menu.dart';

class MediaTile extends ConsumerWidget {
  const MediaTile({required this.file, required this.onTap, super.key});
  final XFile file;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Media(filePath: file.path, width: 64, height: 64),
      title: Text(file.name, overflow: TextOverflow.ellipsis, maxLines: 2),
      subtitle: MediaProgressBars(file: file),
      trailing: MediaPopoverMenu(file: file),
      onTap: onTap,
    );
  }
}

class MediaProgressBars extends StatelessWidget {
  const MediaProgressBars({required this.file, super.key});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(child: ProgressViewUploadMedia(file: file)),
            Expanded(child: ProgressViewFaceRecgMedia(file: file)),
            Expanded(child: Container()),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }
}
