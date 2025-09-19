import 'package:face_it_desktop/modules/media/views/media_popover_menu.dart';
import 'package:face_it_desktop/modules/uploader/views/upload_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'media.dart';

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
      subtitle: MediaUploadStatusView(file: file),
      trailing: MediaPopoverMenu(file: file),
      onTap: onTap,
    );
  }
}
