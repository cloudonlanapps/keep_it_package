import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../models/platform_support.dart';
import '../../../views/common_widgets/action_buttons.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../widgets/media_title.dart';

import 'popover_menu.dart';

class TopBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopBar({
    required this.serverId,
    required this.entityAsync,
    required this.children,
    super.key,
  });
  final String? serverId;
  final AsyncValue<StoreEntity?> entityAsync;
  final ViewerEntities? children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: MediaTitle(entityAsync: entityAsync),
          actions: [
            if (!entityAsync.hasValue || entityAsync.value == null)
              const ContentSourceSelectorIcon(),
            if (entityAsync.hasValue && entityAsync.value == null)
              if (!ColanPlatformSupport.isMobilePlatform)
                CLRefreshButton(
                  onRefresh: () async =>
                      ref.read(reloadProvider.notifier).reload(),
                ),
            const OnDarkMode(),
            ShadButton.ghost(
              onPressed: () => PageManager.of(context).openSettings(),
              child: const Icon(LucideIcons.settings, size: 25),
            ),
            ShadButton.ghost(
              onPressed: () => PageManager.of(context).openAuthenticator(),
              child: const Icon(LucideIcons.user, size: 25),
            ),
          ],
        ),
        if (entityAsync.hasValue && (children?.entities.isNotEmpty ?? false))
          const Row(
            spacing: 8,
            children: [
              Flexible(child: TextFilterBox()),
              FilterPopOverMenu(),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}
