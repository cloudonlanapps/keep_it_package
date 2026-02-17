import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:flutter/widgets.dart';

import 'package:store/store.dart';

import '../../content_store_views/models/entity_actions.dart';
import '../../page_manager.dart';
import '../context_menu.dart';
import 'collection_preview.dart';

class EntityPreview extends StatelessWidget {
  const EntityPreview({
    required this.serverId,
    required this.item,
    required this.entities,
    required this.parentId,
    super.key,
  });

  final StoreEntity item;
  final ViewerEntities entities;
  final int? parentId;
  final String serverId;

  @override
  Widget build(BuildContext context) {
    final entity = item;

    return GetReload(
      builder: (reload) {
        return GetStoreTaskManager(
          contentOrigin: ContentOrigin.move,
          builder: (moveTaskManager) {
            final contextMenu = EntityActions.ofEntity(
              context,
              entity,
              serverId: serverId,
              moveTaskManager: moveTaskManager,
              reload: reload,
            );
            return KeepItContextMenu(
              onTap: () async {
                await PageManager.of(
                  context,
                ).openEntity(entity, serverId: serverId);
                return true;
              },
              contextMenu: contextMenu,
              child: entity.isCollection
                  ? CollectionPreview.preview(
                      entity,
                    )
                  : MediaPreviewWithOverlays(
                      media: entity,
                    ),
            );
          },
        );
      },
    );
  }
}
