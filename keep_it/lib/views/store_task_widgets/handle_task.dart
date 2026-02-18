import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/store_tasks_service/builders/get_active_task.dart';
import 'package:colan_services/store_tasks_service/models/active_store_task.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'items_preview.dart';
import 'keep_with_progress.dart';
import 'pick_collection.dart';
import 'selection_control_icon.dart';
import 'wizard_menu_items.dart';

class HandleTask extends StatelessWidget {
  const HandleTask({required this.onDone, super.key});
  final void Function() onDone;
  @override
  Widget build(BuildContext context) {
    return GetActiveTask(
      builder: (activeTask, actions) {
        return GetSelectionMode(
          builder:
              ({
                required onUpdateSelectionmode,
                required selectionMode,
              }) {
                PreferredSizeWidget? wizard;
                final String title;
                final contentOrigin = activeTask.contentOrigin;

                switch (activeTask.currentStep) {
                  case StoreTaskStep.confirmation:
                    title = contentOrigin.step1Title;
                    final menu = WizardMenuItems.moveOrCancel(
                      type: contentOrigin,
                      keepActionLabel: contentOrigin.positiveAction,
                      deleteActionLabel: contentOrigin.negativeAction,
                      keepAction:
                          (activeTask
                              .currEntities(selectionMode: selectionMode)
                              .isEmpty)
                          ? null
                          : () async {
                              // If action requires confirmation, pop out the dialog
                              actions.setItemsConfirmed(value: true);
                              return true;
                            },
                      deleteAction:
                          (activeTask
                              .currEntities(selectionMode: selectionMode)
                              .isEmpty)
                          ? null
                          : () async {
                              // If action requires confirmation, pop out the dialog
                              actions.setItemsConfirmed(value: false);
                              return false;
                            },
                    );
                    wizard = WizardDialog(
                      option1: menu.option1,
                      option2: menu.option2,
                    );
                  case StoreTaskStep.targetSelection:
                    title = contentOrigin.step2Title;
                    wizard = PickCollection(
                      collection: activeTask.collection,
                      actionLabel: contentOrigin.positiveAction,
                      isValidSuggestion: (collection) => !collection.isDeleted,
                      onDone: (collection) async {
                        if (collection.id != null) {
                          actions.setTarget(collection);
                          return true;
                        }
                        return false;
                      },
                    );
                  case StoreTaskStep.progress:
                    title = contentOrigin.label; // Or "Processing..."
                    wizard = KeepWithProgress(
                      media2Move: ViewerEntities(
                        activeTask.currEntities(selectionMode: selectionMode),
                      ),
                      newParent: activeTask.collection!,
                      onDone: onDone,
                    );
                }

                return WizardLayout2(
                  title: title,
                  onCancel: onDone,
                  actions: [
                    if (activeTask.currentStep == StoreTaskStep.confirmation)
                      if (activeTask.selectable) const SelectionControlIcon(),
                  ],
                  wizard: wizard,
                  child: const WizardPreview(),
                );
              },
        );
      },
    );
  }
}
