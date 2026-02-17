import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:flutter/material.dart';

enum AITaskType { recognize }

enum AITaskPriority implements Comparable<AITaskPriority> {
  user,
  auto;

  int get order => switch (this) {
    user => 0,
    auto => 5,
  };

  @override
  int compareTo(AITaskPriority other) {
    return order.compareTo(other.order);
  }
}

@immutable
abstract class AITask with CLLogger implements Comparable<AITask> {
  AITask({
    required this.identifier,
    required this.taskType,
    this.priority = AITaskPriority.auto,
    this.pre,
    this.post,
  });

  @override
  String get logPrefix => 'AITask';

  final String identifier;
  final AITaskType taskType;
  final AITaskPriority priority; // lower number = higher priority
  final Future<bool> Function(String identifier)? pre;
  final Future<bool> Function(
    String identifier,
    Map<String, dynamic> resultMap,
  )?
  post;

  final Completer<Map<String, dynamic>> _completer = Completer();

  Future<Map<String, dynamic>> get result => _completer.future;
  void complete(Map<String, dynamic> value) => _completer.complete(value);

  @override
  int compareTo(AITask other) {
    return priority.compareTo(other.priority);
  }

  @override
  bool operator ==(covariant AITask other) {
    if (identical(this, other)) return true;

    return other.identifier == identifier &&
        other.taskType == taskType &&
        other.pre == pre &&
        other.post == post;
  }

  @override
  int get hashCode {
    return identifier.hashCode ^
        taskType.hashCode ^
        pre.hashCode ^
        post.hashCode;
  }

  @override
  String toString() {
    return 'AITask(identifier: $identifier, taskType: $taskType, pre: $pre, post: $post)';
  }
}

@immutable
class FaceRecTask extends AITask {
  FaceRecTask({
    required super.identifier,
    required super.priority,
    super.pre,
    super.post,
  }) : super(taskType: AITaskType.recognize);
}
