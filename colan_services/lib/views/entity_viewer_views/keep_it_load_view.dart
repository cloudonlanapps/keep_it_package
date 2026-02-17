import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../page_manager.dart';
import 'top_bar.dart';

class KeepItLoadView extends StatelessWidget {
  const KeepItLoadView({super.key});

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      topMenu: const TopBar(
        serverId: null,
        entity: null,
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
