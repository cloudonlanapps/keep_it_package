import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/media_descriptor.dart';
import '../providers/image_provider.dart';

// stores ExpansionPanel state information
final ImagePicker _picker = ImagePicker();

class ImageBrowser extends ConsumerWidget {
  const ImageBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(availableMediaProvider)
        .when(
          data: (availableMedia) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    // The number of items to build in the list
                    itemCount: availableMedia.items.isEmpty
                        ? 1
                        : availableMedia.items.length,
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    // The builder function that creates each item
                    itemBuilder: (BuildContext context, int index) {
                      if (availableMedia.items.isEmpty) {
                        return ListTile(
                          title: Center(
                            child: Text(
                              "Nothing to show",
                              style: ShadTheme.of(context).textTheme.muted,
                            ),
                          ),
                        );
                      }

                      return ImageTile(media: availableMedia.items[index]);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ShadButton.outline(child: const Text('Import Folder')),
                    ShadButton.outline(
                      child: const Text('Import Image'),
                      onPressed: () async {
                        ref
                            .read(availableMediaProvider.notifier)
                            .addImages(
                              (await _picker.pickMultiImage())
                                  .map(
                                    (image) => MediaDescriptor(
                                      path: image.path,
                                      label: image.name,
                                    ),
                                  )
                                  .toList(),
                            );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
          error: (_, __) => Container(),
          loading: () => Container(),
        );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({super.key, required this.media});
  final MediaDescriptor media;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Image.file(
        File(media.path), // Replace with your image URL
        width: 64,
        height: 64,
      ),
      title: Text(
        media.label,
        style: ShadTheme.of(context).textTheme.small,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: MediaPopover(media: media),
    );
  }
}

class MediaPopover extends ConsumerStatefulWidget {
  const MediaPopover({super.key, required this.media});
  final MediaDescriptor media;

  @override
  ConsumerState<MediaPopover> createState() => _MediaPopoverState();
}

class _MediaPopoverState extends ConsumerState<MediaPopover> {
  final popoverController = ShadPopoverController();

  final List<({String name, String initialValue})> layer = [
    (name: 'Width', initialValue: '100%'),
    (name: 'Max. width', initialValue: '300px'),
    (name: 'Height', initialValue: '25px'),
    (name: 'Max. height', initialValue: 'none'),
  ];

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
            Image.file(
              File(widget.media.path), // Replace with your image URL
            ),
          ],
        ),
      ),
      child: ShadIconButton.outline(
        onPressed: popoverController.toggle,
        icon: Icon(LucideIcons.ellipsis200),
      ),
    );
  }
}
