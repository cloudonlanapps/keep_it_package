import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';

import 'package:store/store.dart';

import '../../page_manager.dart';
import 'bottom_bar_page_view.dart';
import 'top_bar.dart';

class KeepItPageView extends StatelessWidget {
  const KeepItPageView({
    required this.serverId,
    required this.entity,
    required this.siblings,
    super.key,
  });

  final StoreEntity entity;
  final ViewerEntities siblings;
  final String serverId;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
      onSwipe: () {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      },
      child: CLEntitiesPageViewScope(
        siblings: siblings,
        currentEntity: entity,
        child: CLEntitiesPageView(
          topMenuBuilder: (currentEntity) => TopBar(
            serverId: serverId,
            entity: currentEntity as StoreEntity?,
            children: const ViewerEntities([]),
          ),
          bottomMenu: BottomBarPageView(
            serverId: serverId,
          ),
        ),
      ),
    );
  }
}
