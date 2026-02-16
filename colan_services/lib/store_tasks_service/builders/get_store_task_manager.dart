import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content_origin.dart';
import '../models/store_task_manager.dart';
import '../providers/store_tasks.dart';

class GetStoreTaskManager extends ConsumerWidget {
  const GetStoreTaskManager({
    required this.contentOrigin,
    required this.builder,
    super.key,
  });
  final ContentOrigin contentOrigin;
  final Widget Function(StoreTaskManager taskTaskManager) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskTaskManager =
        ref.watch(storeTasksProvider(contentOrigin).notifier);
    return builder(taskTaskManager);
  }
}
