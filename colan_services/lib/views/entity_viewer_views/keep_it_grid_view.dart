import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import '../../services/basic_page_service/widgets/page_manager.dart';
import '../../services/entity_viewer_service/models/entity_actions.dart';
import '../../services/entity_viewer_service/widgets/preview/entity_preview.dart';
import '../../services/entity_viewer_service/widgets/stale_media_banner.dart';
import '../../services/entity_viewer_service/widgets/when_empty.dart';
import 'bottom_bar_grid_view.dart';
import 'top_bar.dart';

class KeepItGridView extends StatelessWidget {
  const KeepItGridView({
    required this.serverId,
    required this.parent,
    required this.children,
    super.key,
  });

  final StoreEntity? parent;
  final ViewerEntities children;
  final String serverId;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
      onSwipe: () {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      },
      child: CLEntitiesGridViewScope(
        child: KeepItGridView0(
          serverId: serverId,
          parent: parent,
          children: children,
        ),
      ),
    );
  }
}

class KeepItGridView0 extends StatelessWidget {
  const KeepItGridView0({
    required this.serverId,
    required this.parent,
    required this.children,
    super.key,
  });

  final StoreEntity? parent;
  final ViewerEntities children;
  final String serverId;

  @override
  Widget build(BuildContext context) {
    final topMenu = TopBar(
      serverId: serverId,
      entity: parent,
      children: children,
    );
    final banners = [
      if (parent == null)
        StaleMediaBanner(
          serverId: serverId,
        ),
    ];
    final bottomMenu = BottomBarGridView(
      entity: parent,
      serverId: serverId,
    );

    return GetReload(
      builder: (reload) {
        return CLScaffold(
          topMenu: topMenu,
          banners: banners,
          bottomMenu: bottomMenu,
          body: OnSwipe(
            onSwipe: () {
              if (PageManager.of(context).canPop()) {
                PageManager.of(context).pop();
              }
            },
            child: CLRefreshWrapper(
              onRefresh: () async => reload(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GetStoreTaskManager(
                  contentOrigin: ContentOrigin.move,
                  builder: (moveTaskManager) {
                    return CLEntitiesGridView(
                      incoming: children,
                      filtersDisabled: false,
                      onSelectionChanged: null,
                      contextMenuBuilder: (context, entities) =>
                          EntityActions.entities(
                            context,
                            entities,
                            moveTaskManager: moveTaskManager,
                            serverId: serverId,
                          ),
                      itemBuilder: (context, item, entities) => EntityPreview(
                        serverId: serverId,
                        item: item as StoreEntity,
                        entities: entities,
                        parentId: parent?.id,
                      ),
                      whenEmpty: const WhenEmpty(),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
