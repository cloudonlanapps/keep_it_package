import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/views/entity_viewer_views/bottom_bar_grid_view.dart';
import 'package:keep_it/views/entity_viewer_views/top_bar.dart';
import 'package:store/store.dart';

import '../page_manager.dart';

class KeepItLoadingView extends CLLoadingView {
  const KeepItLoadingView({
    required this.serverId,
    this.entity,
    this.children,
    this.includeBottomBar = true,
    this.message,
    super.key,
  });

  final String serverId;
  final StoreEntity? entity;
  final ViewerEntities? children;
  final bool includeBottomBar;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return CLLoadingView.page(
      message: message,
      topBar: TopBar(
        entity: entity,
        children: children,
      ),
      bottomMenu: includeBottomBar
          ? BottomBarGridView(
              serverId: serverId,
              entity: entity,
            )
          : null,
      onSwipe: () {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      },
    );
  }
}
