import 'package:colan_widgets/colan_widgets.dart';
import 'package:face_it_desktop/content_manager.dart/providers/candidates.dart';
import 'package:face_it_desktop/views/browser/image_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../utils/menu_button.dart';

final ImagePicker _picker = ImagePicker();

class ImageBrowser extends ConsumerWidget {
  const ImageBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(candidatesProvider.select((e) => e.items));
    return Column(
      children: [
        if (candidates.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nothing to show',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              // The number of items to build in the list
              itemCount: candidates.length,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              // The builder function that creates each item
              itemBuilder: (BuildContext context, int index) {
                return ImageTile(file: candidates[index].file);
              },
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const MenuButton(
              menuItem: CLMenuItem(title: 'Import Folder', icon: Icons.abc),
            ),
            MenuButton(
              menuItem: CLMenuItem(
                title: 'Import Image',
                icon: Icons.abc,
                onTap: () async {
                  ref
                      .read(candidatesProvider.notifier)
                      .append(await _picker.pickMultiImage());
                  return true;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
