import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/store_tasks_service/builders/get_store_tasks.dart';
import 'package:colan_services/store_tasks_service/builders/with_active_task_override.dart';
import 'package:colan_services/store_tasks_service/models/active_store_task.dart';
import 'package:colan_services/store_tasks_service/models/content_origin.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'handle_task.dart';

class StoreTaskWizard extends StatelessWidget {
  const StoreTaskWizard({required this.type, required this.onDone, super.key});
  final String type;
  final void Function({required bool isCompleted}) onDone;

  @override
  Widget build(BuildContext context) {
    final contentOrigin =
        ContentOrigin.values.asNameMap()[type] ?? ContentOrigin.stale;
    return GetStoreTasks(
      contentOrigin: contentOrigin,
      builder: (storeTasks, manager) {
        if (storeTasks.tasks.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onDone(isCompleted: true);
          });
          return WizardLayout(
            title: contentOrigin.label,
            onCancel: () => onDone(isCompleted: false),
            child: const Center(child: Text('Task Queue is empty')),
          );
        }
        final task = storeTasks.tasks.first;
        return SafeArea(
          child: WithActiveTaskOverride(
            task: ActiveStoreTask(
              task: task,
              selectedMedia: const [],
              itemsConfirmed:
                  // You can't modify the item list when move is selected
                  // as move carries already selected items
                  task.contentOrigin == ContentOrigin.move ? true : null,
              // delete will modify with itself, no collection is required.
              targetConfirmed: task.contentOrigin == ContentOrigin.deleted
                  ? true
                  : null,
            ),
            builder: () => CLEntitiesGridViewScope(
              child: HandleTask(onDone: manager.pop),
            ),
          ),
        );
      },
    );
  }
}
