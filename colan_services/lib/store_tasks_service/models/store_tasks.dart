import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'store_task.dart';

@immutable
class StoreTasks {
  const StoreTasks(this.tasks);
  final List<StoreTask> tasks;

  StoreTasks copyWith({
    List<StoreTask>? tasks,
  }) {
    return StoreTasks(
      tasks ?? this.tasks,
    );
  }

  @override
  bool operator ==(covariant StoreTasks other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.tasks, tasks);
  }

  @override
  int get hashCode => tasks.hashCode;

  @override
  String toString() => 'StoreTasks(tasks: $tasks)';
}
