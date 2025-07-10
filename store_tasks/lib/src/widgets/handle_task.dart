import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_task.dart';
import 'items_preview.dart';
import 'keep_with_progress.dart';
import 'pick_collection.dart';
import 'selection_control_icon.dart';
import 'wizard_menu_items.dart';

class HandleTask extends ConsumerWidget {
  const HandleTask({required this.onDone, super.key});
  final void Function() onDone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTask = ref.watch(activeTaskProvider);
    return GetSelectionMode(builder: ({
      required onUpdateSelectionmode,
      required selectionMode,
    }) {
      PreferredSizeWidget? wizard;
      if (activeTask.itemsConfirmed == null) {
        final menu = WizardMenuItems.moveOrCancel(
            type: activeTask.contentOrigin,
            keepActionLabel:
                activeTask.keepActionLabel(selectionMode: selectionMode),
            deleteActionLabel:
                activeTask.deleteActionLabel(selectionMode: selectionMode),
            keepAction: (activeTask
                    .currEntities(selectionMode: selectionMode)
                    .isEmpty)
                ? null
                : () async {
                    // If action requires confirmation, pop out the dialog
                    ref.read(activeTaskProvider.notifier).itemsConfirmed = true;
                    return true;
                  },
            deleteAction:
                (activeTask.currEntities(selectionMode: selectionMode).isEmpty)
                    ? null
                    : () async {
                        // If action requires confirmation, pop out the dialog
                        ref.read(activeTaskProvider.notifier).itemsConfirmed =
                            false;
                        return false;
                      });
        wizard = WizardDialog(option1: menu.option1, option2: menu.option2);
      } else if (activeTask.targetConfirmed == null) {
        wizard = PickCollection(
            collection: activeTask.collection,
            isValidSuggestion: (collection) => !collection.data.isDeleted,
            onDone: (collection) async {
              if (collection.id != null) {
                ref.read(activeTaskProvider.notifier).target = collection;
                return true;
              }
              return false;
            });
      } else {
        wizard = KeepWithProgress(
            media2Move: ViewerEntities(
                activeTask.currEntities(selectionMode: selectionMode)),
            newParent: activeTask.collection!,
            onDone: onDone);
      }

      return WizardLayout2(
        title: activeTask.contentOrigin.label,
        onCancel: onDone,
        actions: [
          if (activeTask.itemsConfirmed == null)
            if (activeTask.selectable) const SelectionControlIcon(),
        ],
        wizard: wizard,
        child: const WizardPreview(),
      );
    });
  }
}
