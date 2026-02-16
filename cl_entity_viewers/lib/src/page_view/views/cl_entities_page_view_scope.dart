import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ui_state.dart';

class CLEntitiesPageViewScope extends ConsumerWidget {
  const CLEntitiesPageViewScope({
    required this.siblings,
    required this.currentEntity,
    required this.child,
    super.key,
  });
  final ViewerEntities siblings;
  final ViewerEntity currentEntity;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedEntities = ViewerEntities(siblings.entities
        .where(
          (e) => [
            CLMediaType.image,
            CLMediaType.video,
          ].contains(e.mediaType),
        )
        .toList());
    return ProviderScope(
      key: ValueKey(supportedEntities.hashCode),
      overrides: [
        mediaViewerUIStateProvider.overrideWith((ref) {
          return MediaViewerUIStateNotifier(
            MediaViewerUIState(
              entities: supportedEntities,
              currentIndex: supportedEntities.entities
                  .indexWhere((e) => e.id == currentEntity.id),
            ),
          );
        }),
      ],
      child: child,
    );
  }
}
