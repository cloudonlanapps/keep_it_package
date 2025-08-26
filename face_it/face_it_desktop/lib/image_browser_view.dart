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
    return BrowserContainer(
      child: ref
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
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ShadButton.outline(
                        child: const Text('Import Folder'),
                        onPressed: () {},
                      ),
                      ShadButton.outline(
                        child: const Text('Import Image'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              );
            },
            error: (_, __) => Container(),
            loading: () => Container(),
          ),
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

class BrowserPlaceHolder extends ConsumerWidget {
  const BrowserPlaceHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrowserContainer();
  }
}

class BrowserContainer extends ConsumerWidget {
  const BrowserContainer({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ShadTheme.of(context).colorScheme.muted),
        ),
      ),
      child: child ?? Text("Place Holder"),
    );
  }
}
