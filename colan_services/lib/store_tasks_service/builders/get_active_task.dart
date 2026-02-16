import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/active_store_task.dart';
import '../providers/active_task_provider.dart';

@immutable
class ActiveTaskActions {
  const ActiveTaskActions({
    required this.setItemsConfirmed,
    required this.setTargetConfirmed,
    required this.setTarget,
    required this.setSelectedMedia,
    required this.remove,
  });

  final void Function({required bool? value}) setItemsConfirmed;
  final void Function({required bool? value}) setTargetConfirmed;
  final void Function(StoreEntity? collection) setTarget;
  final void Function(List<StoreEntity> items) setSelectedMedia;
  final ActiveStoreTask? Function(List<StoreEntity> items) remove;
}

class GetActiveTask extends ConsumerWidget {
  const GetActiveTask({
    required this.builder,
    super.key,
  });

  final Widget Function(ActiveStoreTask task, ActiveTaskActions actions)
      builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(activeTaskProvider);
    final notifier = ref.read(activeTaskProvider.notifier);

    final actions = ActiveTaskActions(
      setItemsConfirmed: ({required value}) => notifier.itemsConfirmed = value,
      setTargetConfirmed: ({required value}) => notifier.targetConfirmed = value,
      setTarget: (collection) => notifier.target = collection,
      setSelectedMedia: (items) => notifier.selectedMedia = items,
      remove: notifier.remove,
    );

    return builder(task, actions);
  }
}
