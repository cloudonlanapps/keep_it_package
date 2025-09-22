import 'dart:async';
import 'package:cl_basic_types/cl_basic_types.dart';
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
  });

  @override
  String get logPrefix => 'AITask';

  final String identifier;
  final AITaskType taskType;
  final AITaskPriority priority; // lower number = higher priority

  final Completer<Map<String, dynamic>> _completer = Completer();

  Future<Map<String, dynamic>> get result => _completer.future;
  void complete(Map<String, dynamic> value) => _completer.complete(value);

  @override
  int compareTo(AITask other) {
    return priority.compareTo(other.priority);
  }
}

@immutable
class FaceRecTask extends AITask {
  FaceRecTask({required super.identifier, required super.priority})
    : super(taskType: AITaskType.recognize);
}
