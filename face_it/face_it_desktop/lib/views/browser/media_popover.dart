import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../modules/content_manager/providers/candidates.dart';
import '../../modules/uploader/providers/uploader.dart';
import '../../modules/server/providers/server_preference.dart';
import '../utils/pop_over_menu_item.dart';

class MediaPopover extends ConsumerStatefulWidget {
  const MediaPopover({required this.file, super.key});
  final XFile file;

  @override
  ConsumerState<MediaPopover> createState() => _MediaPopoverState();
}

class _MediaPopoverState extends ConsumerState<MediaPopover> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(
      candidatesProvider.select(
        (candidates) => candidates.itemByPath(widget.file.path),
      ),
    );
    final pref = ref.watch(serverPreferenceProvider);
    final uploader = ref
        .watch(uploaderProvider)
        .whenOrNull(data: (data) => data);
    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 144,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopOverMenuItem(
              CLMenuItem(
                title: 'Upload',
                icon: clIcons.imageUpload,

                onTap: () async {
                  if (candidate == null || uploader == null) {
                    return;
                  }
                  unawaited(
                    ref
                        .read(uploaderProvider.notifier)
                        .upload(candidate.file.path, pref: pref),
                  );
                  popoverController.hide();
                  return null;
                },
              ),
            ),
            PopOverMenuItem(
              CLMenuItem(
                title: 'Remove',
                icon: clIcons.recycleBin,
                onTap: () async {
                  ref.read(candidatesProvider.notifier).removeByPath([
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
