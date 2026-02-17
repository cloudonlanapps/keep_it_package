import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../page_manager.dart';

class StaleMediaBanner extends ConsumerWidget {
  const StaleMediaBanner({
    required this.serverId,
    super.key,
  });
  final String serverId;

  String get widgetLabel => 'StaleMediaBanner';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreTaskManager(
      contentOrigin: ContentOrigin.stale,
      builder: (staleTaskManager) {
        return GetEntities(
          isHidden: true,
          isCollection: false,
          parentId: 0,
          errorBuilder: (context, error) => const SizedBox.shrink(),
          loadingBuilder: () => CLLoader.widget(debugMessage: widgetLabel),
          builder: (staleMedia) {
            return CLBanner(
              msg: staleMedia.isEmpty
                  ? ''
                  : 'You have ${staleMedia.length} unclassified media. '
                        'Tap here to show',
              onTap: () async {
                staleTaskManager.add(
                  StoreTask(
                    items: staleMedia.entities.cast<StoreEntity>(),
                    contentOrigin: ContentOrigin.stale,
                  ),
                );
                await PageManager.of(context).openWizard(ContentOrigin.stale);
              },
            );
          },
        );
      },
    );
  }
}
