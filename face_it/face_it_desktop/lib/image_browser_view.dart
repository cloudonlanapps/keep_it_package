import 'package:face_it_desktop/models/media_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'providers/image_provider.dart';

// stores ExpansionPanel state information

class ImageBrowser extends ConsumerWidget {
  const ImageBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(availableMediaProvider)
        .when(
          data: (availableMedia) {
            return ListView.builder(
              // The number of items to build in the list
              itemCount: availableMedia.items.isEmpty
                  ? 1
                  : availableMedia.items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            );
          },
          error: (_, __) => Container(),
          loading: () => Container(),
        );
  }
}

class ImportWidget extends StatelessWidget {
  const ImportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(LucideIcons.folderPlus200, size: 24),
                Icon(LucideIcons.imagePlus200, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({super.key, required this.media});
  final MediaDescriptor media;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      /*leading: Image.network(
        media.path, // Replace with your image URL
        width: 32,
        height: 32,
      ),*/
      title: Text(media.label, style: ShadTheme.of(context).textTheme.small),
    );
  }
}
