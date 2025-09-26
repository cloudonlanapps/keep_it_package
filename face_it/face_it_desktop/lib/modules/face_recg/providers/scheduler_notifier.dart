import 'dart:async' show Completer;
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/modules/face_recg/models/ai_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final schedulerNotifierProvider =
    StateNotifierProvider<SchedulerNotifier, List<AITask>>((ref) {
      return SchedulerNotifier(ref);
    });

class SchedulerNotifier extends StateNotifier<List<AITask>> with CLLogger {
  SchedulerNotifier(this.ref) : super([]);
  final Ref ref;
  bool isProcessing = false;
  int count = 0;
  Future<Map<String, dynamic>> pushTask(AITask task) {
    log('${task.identifier}: added into the queue');
    final updated = [...state, task]..sort((a, b) => a.compareTo(b));
    state = updated;
    _processNext();
    return task.result;
  }

  AITask? popTask() {
    if (state.isEmpty) return null;
    final task = state.removeAt(0);
    state = [...state];
    return task;
  }

  @override
  String get logPrefix => 'SchedulerNotifier';

  Future<bool> _processNext({int? myCount}) async {
    final int processId;
    if (myCount == null) {
      processId = count;
      count++;
      if (isProcessing) {
        log('processNext-$processId: unable to start as its already running');
        return false;
      }
    } else {
      processId = myCount;
    }
    isProcessing = true;
    while (isProcessing) {
      final socket = ref
          .read(socketConnectionProvider)
          .whenOrNull(data: (data) => data)
          ?.socket;
      if (socket == null || !socket.connected) {
        isProcessing = false;
        log('processNext-$processId: unable to start as socket not connected');
        return false;
      }
      log('processNext-$processId: Pop a task}');
      final req = popTask();

      if (req == null) {
        log('processNext-$processId: no task found}');
        isProcessing = false;
        break;
      }

      try {
        log('processNext-$processId: process started for ${req.identifier}');
        final result = await process(req, socket: socket, processId: processId);
        log('processNext-$processId: process completed for ${req.identifier}');
        req.complete(result);
      } catch (e) {
        log(
          'processNext-$processId: process completed with error for ${req.identifier}',
        );
        req.complete({'error': '$e'});
      } finally {
        log('processNext-$processId: sleep 200msec');
        await Future<void>.delayed(const Duration(milliseconds: 200));

        // continue next within the same context
      }
    }
    log('processNext-$processId: terminating as the queue is empty');
    return true;
  }

  Future<Map<String, dynamic>> process(
    AITask task, {
    required io.Socket socket,
    required int processId,
  }) async {
    if (task.pre != null) {
      if (!(await task.pre!(task.identifier))) {
        log('processNext-$processId: ${task.identifier}: pre failed');
        return {'error': 'task cancelled'};
      }
    }

    final completer = Completer<Map<String, dynamic>>();

    void callback(dynamic data) {
      final map = data as Map<String, dynamic>;
      if (map.keys.contains('identifier') &&
          map['identifier'] == task.identifier) {
        log('processNext-$processId: ${task.identifier} completed');
        completer.complete(map);
      }
    }

    /// FIXME: [LATER] We may need to add more error checks here?
    /// 1. server generated error
    /// 2. time out
    log(
      'processNext-$processId: ${task.identifier}: request sending to server',
    );
    socket
      ..on('result', callback)
      ..emit(task.taskType.name, task.identifier);
    log(
      'processNext-$processId:  ${task.identifier}: waiting for the response',
    );
    final result = await completer.future;

    socket.off('result', callback);
    log(
      'processNext-$processId: ${task.identifier}: response received $result',
    );
    if (task.post != null) {
      await task.post!(task.identifier, result);
    }
    return result;
  }
}
