import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basic_page_service/widgets/page_manager.dart';
import 'top_bar.dart';

class KeepItLoadView extends ConsumerWidget {
  const KeepItLoadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLScaffold(
      topMenu: const TopBar(
        serverId: null,
        entityAsync: AsyncLoading(),
        children: null,
      ),
      bottomMenu: null,
      banners: const [],
      body: OnSwipe(
        onSwipe: () {
          if (PageManager.of(context).canPop()) {
            PageManager.of(context).pop();
          }
        },
        child: CLLoader.widget(debugMessage: null),
      ),
    );
  }
}
