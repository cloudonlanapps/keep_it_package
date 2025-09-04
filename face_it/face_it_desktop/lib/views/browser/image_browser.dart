import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/media_descriptor.dart';
import '../../providers/image_provider.dart';
import '../utils/menu_button_active_when_socket_connected.dart';
import 'media_popover.dart';

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
                              'Nothing to show',
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
                    const MenuButtonActiveWhenSocketConnected(
                      menuItem: CLMenuItem(
                        title: 'Import Folder',
                        icon: Icons.abc,
                      ),
                    ),
                    MenuButtonActiveWhenSocketConnected(
                      menuItem: CLMenuItem(
                        title: 'Import Image',
                        icon: Icons.abc,
                        onTap: () async {
                          await ref
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
                          return true;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          error: (_, _) => Container(),
          loading: Container.new,
        );
  }
}

class ImageTile extends ConsumerWidget {
  const ImageTile({required this.media, super.key});
  final MediaDescriptor media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
      onTap: () {
        ref.read(availableMediaProvider.notifier).activeMedia = media;
      },
    );
  }
}
