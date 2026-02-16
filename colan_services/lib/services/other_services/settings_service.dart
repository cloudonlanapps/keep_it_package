import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';
import '../../store_tasks_service/store_tasks_service.dart';

import '../basic_page_service/widgets/page_manager.dart';

class SettingsService extends ConsumerWidget {
  const SettingsService({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
