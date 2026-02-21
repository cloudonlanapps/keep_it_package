import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../entity_viewer_views/bottom_bar_grid_view.dart';
import '../entity_viewer_views/top_bar.dart';
import '../page_manager.dart';

class KeepItErrorView extends CLErrorView {
  const KeepItErrorView({
    required this.error,
    required this.serverId,
    this.includeBottomBar = true,
    this.actions,
    super.key,
  });

  final Object error;
  final String serverId;
  final bool includeBottomBar;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return CLErrorView.page(
      message: error.toString(),
      topBar: TopBar(entity: null, children: null),
      bottomMenu: includeBottomBar
          ? BottomBarGridView(serverId: serverId, entity: null)
          : null,
      actions: actions,
      onSwipe: () {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      },
    );
  }
}
