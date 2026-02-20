import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../common_widgets/server_bar.dart';
import '../incoming_media_views/incoming_media_monitor.dart'
    show IncomingMediaMonitor;
import '../page_manager.dart';

class BottomBarGridView extends StatelessWidget implements PreferredSizeWidget {
  const BottomBarGridView({
    required this.serverId,
    required this.entity,
    this.serverBarKey,
    super.key,
  });

  final StoreEntity? entity;
  final String serverId;
  final GlobalKey<ServerBarState>? serverBarKey;

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
            ServerBar(key: serverBarKey),
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
