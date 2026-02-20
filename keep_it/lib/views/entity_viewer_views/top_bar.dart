import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/views/common_widgets/action_buttons.dart';

import 'package:store/store.dart';

import 'media_title.dart';
import 'popover_menu.dart';

class TopBar extends CLTopBar {
  TopBar({
    required StoreEntity? entity,
    required ViewerEntities? children,
    super.key,
  }) : super(
         title: MediaTitle(entity: entity),
         actions: [
           if (entity == null)
             if (!ColanPlatformSupport.isMobilePlatform)
               GetReload(
                 builder: (reload) =>
                     ReloadButton(onReload: () async => reload()),
               ),
           const ThemeToggleButton(),
           const SettingsButton(),
         ],
         bottom: (children?.entities.isNotEmpty ?? false)
             ? const PreferredSize(
                 preferredSize: Size.fromHeight(kToolbarHeight),
                 child: Padding(
                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   child: Row(
                     spacing: 8,
                     children: [
                       Flexible(child: TextFilterBox()),
                       FilterPopOverMenu(),
                     ],
                   ),
                 ),
               )
             : null,
       );
}
