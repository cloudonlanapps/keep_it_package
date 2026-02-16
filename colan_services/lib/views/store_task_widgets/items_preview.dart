import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../../store_tasks_service/builders/get_active_task.dart';

class WizardPreview extends StatefulWidget {
  const WizardPreview({
    super.key,
  });

  @override
  State<WizardPreview> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends State<WizardPreview> {
  StoreEntity? previewItem;

  @override
  Widget build(BuildContext context) {
    return GetActiveTask(builder: (activeTask, actions) {
      return GetSelectionMode(builder: ({
        required onUpdateSelectionmode,
        required selectionMode,
      }) {
        final media0 = activeTask.itemsConfirmed == null
            ? activeTask.items
            : activeTask.currEntities(selectionMode: selectionMode);

        return ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16)),
          child: media0.isEmpty
              ? const Center(child: Text('Nothing to show'))
              : CLEntitiesGridView(
                  incoming: ViewerEntities(media0),
                  filtersDisabled: true,
                  whenEmpty: const Text('Nothing to show here'),

                  // Wizard don't use context menu
                  contextMenuBuilder: null,
                  onSelectionChanged: (items) =>
                      actions.setSelectedMedia(items.entities.cast()),
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
    });
  }
}
