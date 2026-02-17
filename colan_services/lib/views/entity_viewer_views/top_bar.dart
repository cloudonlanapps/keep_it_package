import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../init_service/models/platform_support.dart';
import '../page_manager.dart';
import 'media_title.dart';
import 'popover_menu.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    required this.serverId,
    required this.entity,
    required this.children,
    super.key,
  });
  final String? serverId;
  final StoreEntity? entity;
  final ViewerEntities? children;

  @override
  Widget build(BuildContext context) {
    return GetReload(
      builder: (reload) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: MediaTitle(entity: entity),
              actions: [
                if (entity == null) const ContentSourceSelector(),
                if (entity == null)
                  if (!ColanPlatformSupport.isMobilePlatform)
                    CLRefreshButton(
                      onRefresh: () async => reload(),
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
            if (children?.entities.isNotEmpty ?? false)
              const Row(
                spacing: 8,
                children: [
                  Flexible(child: TextFilterBox()),
                  FilterPopOverMenu(),
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}
