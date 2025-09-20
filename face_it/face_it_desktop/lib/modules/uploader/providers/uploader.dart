import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:face_it_desktop/modules/server/providers/upload_url_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_state.dart';
import '../models/upload_status.dart';
import '../models/uploader.dart';

final uploaderProvider = StateNotifierProvider<UploaderNotifier, Uploader>(
  UploaderNotifier.new,
);

class UploaderNotifier extends StateNotifier<Uploader> with CLLogger {
  UploaderNotifier(this.ref) : super(const Uploader({}));
  final Ref ref;
  @override
  String get logPrefix => 'UploaderNotifier';

  String add(String filePath) {
    if (!state.files.keys.contains(filePath)) {
      state = Uploader({
        ...state.files,
        filePath: UploadState(filePath: filePath),
      });
    }
    log('added 1 item into state (has ${state.files.length}) total items');
    return filePath;
  }

  Iterable<String> addMultiple(Iterable<String> filePaths) {
    if (filePaths.isNotEmpty) {
      final newFilePaths = filePaths.where(
        (filePath) => !state.files.keys.contains(filePath),
      );
      if (newFilePaths.isNotEmpty) {
        state = Uploader({
          ...state.files,
          for (final file in newFilePaths) file: UploadState(filePath: file),
        });
      }
    }
    log(
      'added ${filePaths.length} items into state (has ${state.files.length}) total items',
    );
    return filePaths;
  }

  Future<void> uploadMultiple(Iterable<String> filePaths) async {
    if (filePaths.isEmpty) {
      return;
    }
    final files = addMultiple(filePaths);

    await Future.wait(files.map(_upload));
  }

  Future<void> upload(String filePath) async {
    await _upload(add(filePath));
  }

  void updateState({
    required String filePath,
    required UploadState uploadState,
  }) {
    state = Uploader({...state.files, filePath: uploadState});
  }

  Future<void> _upload(String filePath) async {
    if (state.files[filePath]?.status == UploadStatus.success ||
        state.files[filePath]?.status == UploadStatus.uploading) {
      // avoid redundent upload.
      return;
    }

    final uploader = state;

    if (!uploader.files.keys.contains(filePath)) {
      return;
    }
    final url = ref.read(uploadURLProvider);
    if (url == null) return;
    final task = UploadTask.fromFile(
      file: File(state.files[filePath]!.filePath),
      url: url,
      fileField: 'media',
      updates: Updates.progress, // request status and progress updates
    );

    unawaited(startUpload(task));
  }

  void updateUploadError(String filePath, String? e) {
    log('$filePath: error: $e');
    final updated = state.files[filePath]!.copyWith(
      serverResponse: () => null,
      status: UploadStatus.error,
      entity: () => null,
      error: () => e ?? 'Empty response',
    );
    updateState(filePath: filePath, uploadState: updated);
  }

  void updateUploadPending(String filePath, String? e) {
    log('$filePath: error: $e');
    final updated = state.files[filePath]!.copyWith(
      serverResponse: () => null,
      status: UploadStatus.pending,
      entity: () => null,
      error: () => e ?? 'Empty response',
    );
    updateState(filePath: filePath, uploadState: updated);
  }

  void updateUploadResponse(String filePath, String? response) {
    if (response == null || (response.isEmpty)) {
      throw Exception('Empty response');
    }
    final clEntity = UploadState.entityFromMap(
      jsonDecode(response) as Map<String, dynamic>,
    );
    log('$filePath: response: ${clEntity.label}');
    final updated = state.files[filePath]!.copyWith(
      serverResponse: () => response,
      status: UploadStatus.success,
      entity: () => clEntity,
      error: () => null,
    );
    updateState(filePath: filePath, uploadState: updated);
  }

  Future<void> startUpload(UploadTask task) async {
    final filePath = await task.filePath();

    final result = await FileDownloader()
        .upload(
          task,

          onProgress: (progress) {
            final updated = state.files[filePath]!.copyWith(
              serverResponse: () => '${(progress * 100).toStringAsFixed(1)}%',
            );
            updateState(filePath: filePath, uploadState: updated);
          },
        )
        .catchError((dynamic e) async {
          log('${task.filename}: Exception occured: $e');
          updateUploadError(filePath, '$e'); // may not be required?
          return TaskStatusUpdate(task, TaskStatus.failed, TaskException('$e'));
        });
    log('${task.filename}: ${result.status}');
    final url = ref.read(uploadURLProvider);
    if (url == null) {
      updateUploadPending(filePath, null);
    } else if (result.status.isFinalState) {
      switch (result.status) {
        case TaskStatus.complete:
          try {
            updateUploadResponse(filePath, result.responseBody);
          } catch (e) {
            updateUploadError(filePath, '$e');
          }

        case TaskStatus.failed:
          updateUploadError(filePath, '${result.exception}');

        case TaskStatus.canceled:
          updateUploadPending(filePath, null);

        case TaskStatus.enqueued:
        case TaskStatus.running:
        case TaskStatus.notFound:
        case TaskStatus.waitingToRetry:
        case TaskStatus.paused:
          break;
      }
    }
  }

  Future<void> retryNew() async {
    await resetNew();

    final pendingItems = state.files.values;
    log(
      'resetting ${pendingItems.length} pendingItems in state (has ${state.files.length}) items',
    );
    for (final item in pendingItems) {
      await _upload(item.filePath);
    }
  }

  Future<void> resetNew() async {
    await cancelAllTasks();
    final items = {
      for (final item in state.files.entries)
        item.key: item.value.copyWith(
          serverResponse: () => null,
          status: UploadStatus.pending,
          entity: () => null,
          error: () => null,
        ),
    };
    log(
      'resetting ${items.length} items in state (had ${state.files.length}) items',
    );
    state = Uploader(items);
  }

  Future<void> cancelAllTasks() async {
    // This cancels *all* tasks managed by background_downloader
    await FileDownloader().cancelTasksWithIds(
      (await FileDownloader().allTasks()).map((t) => t.taskId).toList(),
    );
  }
}
