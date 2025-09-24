import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
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
                title: uploadState == null
                    ? 'Upload'
                    : (url == null)
                    ? switch (uploadState.uploadStatus) {
                        UploadStatus.success => 'Uploaded',
                        UploadStatus.pending => 'Cancel Upload',
                        UploadStatus.error => "Can't upload",
                        UploadStatus.uploading => 'Cancel Upload',
                        UploadStatus.ignore => "Can't upload",
                      }
                    : switch (uploadState.uploadStatus) {
                        UploadStatus.success => 'Uploaded',
                        UploadStatus.pending => 'Cancel Upload',
                        UploadStatus.error => 'Retry Upload',
                        UploadStatus.uploading => 'uploading',
                        UploadStatus.ignore => 'Upload',
                      },
                icon: clIcons.imageUpload,
                onTap: uploadState == null
                    ? onUpload
                    : (url == null)
                    ? switch (uploadState.uploadStatus) {
                        UploadStatus.success => null,
                        UploadStatus.pending => onCancel,
                        UploadStatus.error => null,
                        UploadStatus.uploading => onCancel,
                        UploadStatus.ignore => null,
                      }
                    : switch (uploadState.uploadStatus) {
                        UploadStatus.success => null,
                        UploadStatus.pending => onCancel,
                        UploadStatus.error => onUpload,
                        UploadStatus.uploading => null,
                        UploadStatus.ignore => onUpload,
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
