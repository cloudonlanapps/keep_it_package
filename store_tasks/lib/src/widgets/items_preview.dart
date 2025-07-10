import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../providers/active_task.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  StoreEntity? previewItem;

  @override
  Widget build(BuildContext context) {
    return GetSelectionMode(builder: ({
      required onUpdateSelectionmode,
      required selectionMode,
    }) {
      final activeTask = ref.watch(activeTaskProvider);
      final media0 = activeTask.itemsConfirmed == null
          ? activeTask.items
          : activeTask.currEntities(selectionMode: selectionMode);

      return ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
        child: media0.isEmpty
            ? const Center(child: Text('Nothing to show'))
            : CLEntitiesGridView(
                incoming: ViewerEntities(media0),
                filtersDisabled: true,
                whenEmpty: const Text('Nothing to show here'),

                // Wizard don't use context menu
                contextMenuBuilder: null,
                onSelectionChanged: (items) => ref
                    .read(activeTaskProvider.notifier)
                    .selectedMedia = items.entities.cast(),
                itemBuilder: (context, item, entities) {
                  final Widget widget;
                  if (item.isCollection) {
                    widget = LayoutBuilder(
                      builder: (context, constrain) {
                        return Image.asset(
                          'assets/icon/icon.png',
                          width: constrain.maxWidth,
                          height: constrain.maxHeight,
                        );
                      },
                    );
                  } else {
                    widget = MediaThumbnail(
                      media: item,
                    );
                  }
                  return widget;
                },
              ),
      );
    });
  }
}
