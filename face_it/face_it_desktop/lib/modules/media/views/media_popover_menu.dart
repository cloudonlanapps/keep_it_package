import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:colan_widgets/colan_widgets.dart';
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

    ref.watch(uploaderProvider);
    CLSocket? session;
    CLServer? server;
    session = ref
        .watch(socketConnectionProvider)
        .whenOrNull(data: (data) => data.socket.connected ? data : null);
    server = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (data) => (data?.connected ?? false) ? data : null);
    final url = ref.watch(uploadURLProvider);
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

                onTap: (url != null)
                    ? () async {
                        if (candidate == null) {
                          return;
                        }

                        unawaited(
                          ref
                              .read(uploaderProvider.notifier)
                              .upload(candidate.file.path, url),
                        );
                        popoverController.hide();
                        return null;
                      }
                    : null,
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
