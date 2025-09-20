import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/modules/uploader/models/upload_state.dart';
import 'package:face_it_desktop/modules/uploader/models/upload_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../server/providers/upload_url_provider.dart';
import '../../uploader/providers/uploader.dart';
import '../../utils/pop_over_menu_item.dart';
import '../providers/candidates.dart';

class MediaPopoverMenu extends ConsumerStatefulWidget {
  const MediaPopoverMenu({required this.file, super.key});
  final XFile file;

  @override
  ConsumerState<MediaPopoverMenu> createState() => MediaPopoverMenuState();
}

class MediaPopoverMenuState extends ConsumerState<MediaPopoverMenu> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(
      mediaListProvider.select(
        (candidates) => candidates.itemByPath(widget.file.path),
      ),
    );
    if (candidate == null) {
      return const ShadIconButton.outline(
        enabled: false,
        icon: Icon(LucideIcons.ellipsis200),
      );
    }

    final uploadState = ref.watch(
      uploaderProvider.select((e) => e.files[candidate.file.path]),
    );

    final url = ref.watch(uploadURLProvider);

    final uploadMenuItem = switch (uploadState) {
      null => CLMenuItem(
        title: 'Upload',
        icon: clIcons.imageUpload,

        onTap: (url != null)
            ? () async {
                unawaited(
                  ref
                      .read(uploaderProvider.notifier)
                      .upload(candidate.file.path),
                );
                popoverController.hide();
                return null;
              }
            : null,
      ),
      (final UploadState state) when state.status == UploadStatus.success =>
        CLMenuItem(title: 'Uploaded', icon: clIcons.imageUpload),
      (final UploadState state) when state.status == UploadStatus.pending =>
        CLMenuItem(title: 'Cancel Upload', icon: clIcons.imageUpload),

      (final UploadState state) when state.status == UploadStatus.error =>
        CLMenuItem(
          title: 'Retry Upload',
          icon: clIcons.imageUpload,

          onTap: (url != null)
              ? () async {
                  unawaited(
                    ref
                        .read(uploaderProvider.notifier)
                        .upload(candidate.file.path),
                  );
                  popoverController.hide();
                  return null;
                }
              : null,
        ),
      _ => null,
    };

    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 144,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (uploadMenuItem != null) PopOverMenuItem(uploadMenuItem),

            PopOverMenuItem(
              CLMenuItem(
                title: 'Remove',
                icon: clIcons.recycleBin,
                onTap: () async {
                  ref.read(mediaListProvider.notifier).removeByPath([
                    widget.file.path,
                  ]);
                  popoverController.hide();
                  return true;
                },
                isDestructive: true,
              ),
            ),
          ],
        ),
      ),
      child: ShadIconButton.outline(
        onPressed: popoverController.toggle,
        icon: const Icon(LucideIcons.ellipsis200),
      ),
    );
  }
}
