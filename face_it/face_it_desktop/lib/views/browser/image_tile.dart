import 'dart:io';

import 'package:face_it_desktop/modules/uploader/views/upload_status.dart';
import 'package:face_it_desktop/views/browser/media_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../modules/content_manager/providers/candidates.dart';
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
      subtitle: UploadStatusView(file: file),
      trailing: MediaPopover(file: file),
      onTap: () {
        ref.read(activeMainContentTypeProvider.notifier).state =
            MainContentType.images;
        ref.read(candidatesProvider.notifier).setActiveFile(file.path);
      },
    );
  }
}
