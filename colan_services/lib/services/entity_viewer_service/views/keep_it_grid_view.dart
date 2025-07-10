import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';
import 'package:store_tasks/store_tasks.dart';

import '../models/entity_actions.dart';
import '../widgets/on_swipe.dart';
import '../widgets/preview/entity_preview.dart';
import '../widgets/refresh_button.dart';
import '../widgets/stale_media_banner.dart';
import '../widgets/when_empty.dart';
import 'bottom_bar_grid_view.dart';
import 'top_bar.dart';

class KeepItGridView extends StatelessWidget {
  const KeepItGridView(
      {required this.serverId,
      required this.parent,
      required this.children,
      super.key});

  final StoreEntity? parent;
  final ViewerEntities children;
  final String serverId;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
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

class KeepItGridView0 extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final topMenu = TopBar(
      serverId: serverId,
      entityAsync: AsyncData(parent),
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

    return CLScaffold(
      topMenu: topMenu,
      banners: banners,
      bottomMenu: bottomMenu,
      body: OnSwipe(
        child: OnRefreshWrapper(
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
                        EntityActions.entities(context, entities,
                            moveTaskManager: moveTaskManager,
                            serverId: serverId),
                    itemBuilder: (context, item, entities) => EntityPreview(
                      serverId: serverId,
                      item: item as StoreEntity,
                      entities: entities,
                      parentId: parent?.id,
                    ),
                    whenEmpty: const WhenEmpty(),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
