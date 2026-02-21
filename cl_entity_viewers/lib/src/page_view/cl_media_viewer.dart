import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cl_basic_types/viewer_types.dart';

import 'providers/ui_state.dart';
import 'views/media_viewer_core.dart';

class CLEntitiesPageView extends ConsumerWidget {
  const CLEntitiesPageView({
    required this.topMenuBuilder,
    required this.bottomMenu,
    this.onLoadMore,
    this.faceOverlayBuilder,
    super.key,
  });

  final CLTopBar Function(ViewerEntity? entity) topMenuBuilder;
  final PreferredSizeWidget bottomMenu;
  final Future<void> Function()? onLoadMore;

  /// Optional builder for face overlay.
  /// Called with the current entity to build a face overlay widget.
  /// The overlay is positioned on top of the media viewer.
  final Widget Function(ViewerEntity entity)? faceOverlayBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMenu = ref.watch(
      mediaViewerUIStateProvider.select((e) => e.showMenu),
    );
    final currentItem = ref.watch(
      mediaViewerUIStateProvider.select((e) => e.currentItem),
    );
    if (showMenu) {
      return CLScaffold(
        topMenu: topMenuBuilder(currentItem),
        body: SafeArea(
          child: MediaViewerCore(
            onLoadMore: onLoadMore,
            faceOverlayBuilder: faceOverlayBuilder,
          ),
        ),
        bottomMenu: bottomMenu,
      );
    } else {
      return CLScaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: MediaViewerCore(
            onLoadMore: onLoadMore,
            faceOverlayBuilder: faceOverlayBuilder,
          ),
        ),
      );
    }
  }
}
