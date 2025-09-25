import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/modules/uploader/models/upload_state.dart';
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

  Future<bool> onUpload() async {
    unawaited(ref.read(uploaderProvider.notifier).upload(widget.file.path));
    popoverController.hide();
    return true;
  }

  Future<bool> onCancel() async {
    unawaited(ref.read(uploaderProvider.notifier).cancel(widget.file.path));
    popoverController.hide();
    return true;
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

    final url = ref.watch(uploadURLProvider);
    final uploadMenuItem = CLMenuItem(
      title: 'Upload',
      icon: clIcons.imageUpload,
      onTap: onUpload,
    );
    final uploadCancelMenuItem = CLMenuItem(
      title: 'Cancel Upload',
      icon: clIcons.imageUpload,
      onTap: onCancel,
    );
    final uploadedMenuItem = CLMenuItem(
      title: 'Uploaded',
      icon: clIcons.imageUpload,
    );

    final menuItem = switch (uploadState) {
      null => uploadMenuItem,
      (final UploadState _) when uploadState.ignored => uploadMenuItem,
      (final UploadState _) when uploadState.uploadProgress == null =>
        uploadCancelMenuItem,
      (final UploadState _)
          when uploadState.uploadProgress?.status == TaskStatus.complete =>
        uploadedMenuItem,

      _ => CLMenuItem(
        title: 'unexpected',
        icon: clIcons.imageUpload,
        onTap: () async {
          log(ref.read(uploaderProvider).currentStatus);
          return true;
        },
      ),
    };

    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 144,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopOverMenuItem(menuItem),
            PopOverMenuItem(
              CLMenuItem(
                title: 'dump',
                icon: LucideIcons.ambulance,
                onTap: () async {
                  log(uploadState.toString());
                  popoverController.hide();
                  return true;
                },
              ),
            ),
            FaceScannerContextMenu(
              filePath: candidate.path,
              onDone: popoverController.hide,
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

class FaceScannerContextMenu extends ConsumerWidget {
  const FaceScannerContextMenu({
    required this.filePath,
    required this.onDone,
    super.key,
  });
  final String filePath;
  final void Function()? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanReady = ref
        .watch(uploaderProvider.notifier)
        .isScanReady(filePath);
    final hasFaces = ref.watch(
      uploaderProvider.select(
        (e) => e.files[filePath]?.faces?.isNotEmpty ?? false,
      ),
    );
    return PopOverMenuItem(
      CLMenuItem(
        title: hasFaces ? 'Rescan for Face' : 'Scan For Face',
        icon: LucideIcons.scanFace,
        onTap: isScanReady
            ? () async {
                unawaited(
                  ref
                      .read(uploaderProvider.notifier)
                      .scanForFaceByPath(filePath, forced: true),
                );
                onDone?.call();
                return null;
              }
            : null,
      ),
    );
  }
}
