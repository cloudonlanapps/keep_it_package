import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../main/models/main_content_type.dart';
import '../../../main/providers/main_content_type.dart';

class SavedItemsBrowser extends ConsumerWidget {
  const SavedItemsBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      SavedItemTile(
        menuItem: CLMenuItem(
          title: 'CollectedFaces',
          icon: LucideIcons.scanFace300,
          onTap: () async {
            ref.read(activeMainContentTypeProvider.notifier).state =
                MainContentType.faces;

            return null;
          },
        ),
      ),
      SavedItemTile(
        menuItem: CLMenuItem(
          title: 'Known Persons',
          icon: LucideIcons.userCog,
          onTap: () async {
            ref.read(activeMainContentTypeProvider.notifier).state =
                MainContentType.persons;
            return null;
          },
        ),
      ),
    ];

    return ListView.builder(
      // The number of items to build in the list
      itemCount: tiles.length,
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      // The builder function that creates each item
      itemBuilder: (BuildContext context, int index) {
        return tiles[index];
      },
    );
  }
}

class SavedItemTile extends StatelessWidget {
  const SavedItemTile({required this.menuItem, super.key});
  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: SizedBox(
        width: 64,
        height: 64,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(fit: BoxFit.cover, child: Icon(menuItem.icon)),
        ),
      ),
      title: Text(menuItem.title, overflow: TextOverflow.ellipsis, maxLines: 2),
      onTap: menuItem.onTap,
    );
  }
}
