import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content_origin.dart';
import '../models/store_task.dart';
import '../models/store_task_manager.dart';
import '../models/store_tasks.dart';

class StoreTasksNotifier extends StateNotifier<StoreTasks>
    implements StoreTaskManager {
  StoreTasksNotifier() : super(const StoreTasks([]));

  @override
  bool add(StoreTask task) {
    state = StoreTasks([...state.tasks, task]);
    return true;
  }

  @override
  StoreTask? pop() {
    final task = state.tasks.firstOrNull;
    state = StoreTasks(state.tasks.length > 1 ? state.tasks.sublist(1) : []);
    return task;
  }
}

final StateNotifierProviderFamily<StoreTasksNotifier, StoreTasks, ContentOrigin>
storeTasksProvider =
    StateNotifierProvider.family<StoreTasksNotifier, StoreTasks, ContentOrigin>(
      (ref, taskType) {
        return StoreTasksNotifier();
      },
    );
