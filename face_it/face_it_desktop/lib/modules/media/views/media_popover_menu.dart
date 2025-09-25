import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../uploader/providers/uploader.dart';
import '../../utils/pop_over_menu_item.dart';
import '../providers/candidates.dart';

class MediaPopoverMenu extends ConsumerStatefulWidget {
  const MediaPopoverMenu({required this.file, super.key});
  final XFile file;

  @override
  ConsumerState<MediaPopoverMenu> createState() => MediaPopoverMenuState();
}

class MediaPopoverMenuState extends ConsumerState<MediaPopoverMenu>
    with CLLogger {
  final popoverController = ShadPopoverController();

  @override
  String get logPrefix => 'MediaPopoverMenuState';

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
      uploaderProvider.select((e) => e.files[candidate.path]),
    );

    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 144,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopOverMenuItem(
              ref
                  .read(uploaderProvider.notifier)
                  .getUploadContextMenuItem(
                    widget.file.path,
                    onDone: popoverController.hide,
                  ),
            ),
            PopOverMenuItem(
              CLMenuItem(
                title: 'debug-dump',
                icon: LucideIcons.ambulance,
                onTap: () async {
                  log(uploadState.toString());
                  popoverController.hide();
                  return true;
                },
              ),
            ),

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
