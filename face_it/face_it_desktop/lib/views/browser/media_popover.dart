import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../content_manager.dart/providers/candidates.dart';

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
                // FIXME: Network actions here, if needed
                Expanded(child: Text(widget.file.name, style: textTheme.lead)),
                ShadIconButton.outline(
                  onPressed: () {
                    ref.read(candidatesProvider.notifier).removeByPath([
                      widget.file.path,
                    ]);
                    popoverController.toggle();
                  },
                  icon: Icon(
                    LucideIcons.trash,
                    color: ShadTheme.of(context).colorScheme.destructive,
                  ),
                ),
              ],
            ),
            Image.file(File(widget.file.path), width: 256),
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
