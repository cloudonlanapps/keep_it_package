import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/active_store_task.dart';
import '../providers/active_task_provider.dart';

/// Builder that overrides activeTaskProvider with a specific task
class WithActiveTaskOverride extends StatelessWidget {
  const WithActiveTaskOverride({
    required this.task,
    required this.builder,
    super.key,
  });

  final ActiveStoreTask task;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        activeTaskProvider.overrideWith((ref) => ActiveTaskNotifier(task))
      ],
      child: builder(),
    );
  }
}
