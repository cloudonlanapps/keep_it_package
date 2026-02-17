import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../init_service/models/platform_support.dart';
import '../../services/basic_page_service/widgets/page_manager.dart';

class BottomBarGridView extends StatelessWidget implements PreferredSizeWidget {
  const BottomBarGridView({
    required this.serverId,
    required this.entity,
    super.key,
  });

  final StoreEntity? entity;
  final String serverId;

  @override
  Widget build(BuildContext context) {
    return GetIncomingMedia(
      builder: (incomingMedia, actions) => Padding(
        padding: EdgeInsets.only(
          bottom:
              (ColanPlatformSupport.isMobilePlatform ? 0 : 8) +
              MediaQuery.of(context).padding.bottom,
          top: 8,
          left: 8,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ServerBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShadButton.ghost(
                  child: clIcons.insertItem.iconFormatted(),
                  onPressed: () {
                    unawaited(
                      IncomingMediaMonitor.onPickFiles(
                        context,
                        actions,
                        collection: entity,
                      ),
                    );
                  },
                ),
                if (ColanPlatformSupport.cameraSupported)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShadButton.ghost(
                      child: clIcons.camera.iconFormatted(),
                      onPressed: () {
                        unawaited(
                          PageManager.of(
                            context,
                          ).openCamera(
                            parentId: entity?.id,
                            serverId: serverId,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
