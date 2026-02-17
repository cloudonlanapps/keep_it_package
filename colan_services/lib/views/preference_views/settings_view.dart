import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../page_manager.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      topMenu: AppBar(
        title: Text(
          'Settings',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      bottomMenu: null,
      banners: const [],
      body: GetStoreTaskManager(
        contentOrigin: ContentOrigin.deleted,
        builder: (deletedTaskManager) {
          return GetEntities(
            isDeleted: true,
            isHidden: null,
            parentId: 0,
            errorBuilder: (_, _) {
              throw UnimplementedError('errorBuilder');
            },
            loadingBuilder: () => CLLoader.widget(
              debugMessage: 'GetDeletedMedia',
            ),
            builder: (deletedMedia) {
              return ListView(
                children: [
                  if (deletedMedia.isNotEmpty)
                    ListTile(
                      leading: clIcons.recycleBin.iconFormatted(),
                      trailing: IconButton(
                        icon: clIcons.gotoPage.iconFormatted(),
                        onPressed: () async {
                          deletedTaskManager.add(
                            StoreTask(
                              items: deletedMedia.entities.cast<StoreEntity>(),
                              contentOrigin: ContentOrigin.stale,
                            ),
                          );
                          await PageManager.of(
                            context,
                          ).openWizard(ContentOrigin.deleted);
                        },
                      ),
                      title: Text('Deleted Items (${deletedMedia.length})'),
                    ),
                  const StorageMonitor(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
