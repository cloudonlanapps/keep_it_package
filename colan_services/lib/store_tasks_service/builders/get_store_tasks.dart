import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content_origin.dart';
import '../models/store_task_manager.dart';
import '../models/store_tasks.dart';
import '../providers/store_tasks.dart';

class GetStoreTasks extends ConsumerWidget {
  const GetStoreTasks({
    required this.contentOrigin,
    required this.builder,
    super.key,
  });

  final ContentOrigin contentOrigin;
  final Widget Function(StoreTasks tasks, StoreTaskManager manager) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(storeTasksProvider(contentOrigin));
    final manager = ref.read(storeTasksProvider(contentOrigin).notifier);

    return builder(tasks, manager);
  }
}
