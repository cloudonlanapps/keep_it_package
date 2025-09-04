import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/media_descriptor.dart';
import '../../providers/image_provider.dart';

class MediaPopover extends ConsumerStatefulWidget {
  const MediaPopover({required this.media, super.key});
  final MediaDescriptor media;

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
    final textTheme = ShadTheme.of(context).textTheme;
    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 288,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(widget.media.label, style: textTheme.lead),
                ),
                ShadIconButton.outline(
                  onPressed: () {
                    ref
                        .read(availableMediaProvider.notifier)
                        .removeImagesByPath([widget.media.path]);
                    popoverController.toggle();
                  },
                  icon: Icon(
                    LucideIcons.trash,
                    color: ShadTheme.of(context).colorScheme.destructive,
                  ),
                ),
              ],
            ),
            Image.file(File(widget.media.path), width: 256),
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
