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
    super.key,
  });

  final PreferredSizeWidget Function(ViewerEntity? entity) topMenuBuilder;
  final PreferredSizeWidget bottomMenu;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMenu =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.showMenu));
    final currentItem =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.currentItem));
    if (showMenu) {
      return CLScaffold(
        topMenu: topMenuBuilder(currentItem),
        banners: const [],
        body: SafeArea(
          child: MediaViewerCore(),
        ),
        bottomMenu: bottomMenu,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: MediaViewerCore(),
        ),
      );
    }
  }
}
