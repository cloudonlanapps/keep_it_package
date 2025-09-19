import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/modules/media/providers/candidates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/models/main_content_type.dart';
import '../../../app/providers/main_content_type.dart';
import '../../uploader/views/upload_status.dart';
import '../../utils/menu_button.dart';
import 'media.dart';
import 'media_popover_menu.dart';

final ImagePicker _picker = ImagePicker();

class MediaBrowser extends ConsumerWidget {
  const MediaBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(mediaListProvider.select((e) => e.mediaList));
    return Column(
      children: [
        if (candidates.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nothing to show',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              // The number of items to build in the list
              itemCount: candidates.length,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              // The builder function that creates each item
              itemBuilder: (BuildContext context, int index) {
                return MediaTile(
                  file: candidates[index].file,
                  onTap: () {
                    ref.read(activeMainContentTypeProvider.notifier).state =
                        MainContentType.images;
                    ref
                        .read(mediaListProvider.notifier)
                        .setActiveFile(candidates[index].file.path);
                  },
                );
              },
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const Expanded(
              child: MenuButton(
                menuItem: CLMenuItem(title: 'Import Folder', icon: Icons.abc),
              ),
            ),
            Expanded(
              child: MenuButton(
                menuItem: CLMenuItem(
                  title: 'Import Image',
                  icon: Icons.abc,
                  onTap: () async {
                    ref
                        .read(mediaListProvider.notifier)
                        .append(await _picker.pickMultiImage());
                    return true;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
