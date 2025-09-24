import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart' show detectedFacesProvider;
import 'package:content_store/content_store.dart';
import 'package:face_it_desktop/modules/server/providers/upload_url_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media/providers/candidates.dart';
import '../models/upload_state.dart';
import '../models/upload_status.dart';
import '../models/uploader.dart';

final uploaderProvider = StateNotifierProvider<UploaderNotifier, Uploader>((
  ref,
) {
  final tempDirectory = ref
      .watch(deviceDirectoriesProvider)
      .whenOrNull(data: (data) => data.temporary.path);
  return UploaderNotifier(ref, downloadPath: tempDirectory);
});

class UploaderNotifier extends StateNotifier<Uploader> with CLLogger {
  UploaderNotifier(this.ref, {required this.downloadPath})
    : super(const Uploader({}));
  final Ref ref;
  final String? downloadPath;
  @override
  String get logPrefix => 'UploaderNotifier';

  UploadState add(String filePath) {
    if (!state.files.keys.contains(filePath) ||
        (state.files[filePath]!.uploadStatus == UploadStatus.ignore)) {
      state = Uploader({
        ...state.files,
        filePath: UploadState(filePath: filePath),
      });
    }

    log('added 1 item into state (has ${state.files.length}) total items');
    return state.files[filePath]!;
  }

  Iterable<UploadState> addMultiple(Iterable<String> filePaths) {
    if (filePaths.isNotEmpty) {
      final newFilePaths = filePaths.where(
        (filePath) => !state.files.keys.contains(filePath),
      );
      final forceAgain = filePaths.where(
        (filePath) =>
            state.files.keys.contains(filePath) &&
            state.files[filePath]!.uploadStatus == UploadStatus.ignore,
      );
      log('new files found ${newFilePaths.length}');
      log('focing files with ignore: ${forceAgain.length}');
      if (newFilePaths.isNotEmpty) {
        state = Uploader({
          ...state.files,
          for (final file in [...newFilePaths, ...forceAgain])
            file: UploadState(filePath: file),
        });
      }
    }
    log(
      'added ${filePaths.length} items into state (has ${state.files.length}) total items',
    );
    return state.files.values;
  }

  Future<void> uploadMultiple(Iterable<String> filePaths) async {
    if (filePaths.isEmpty) {
      return;
    }
    final files = addMultiple(filePaths);

    final filesNotYetuploaded = files.where((e) => e.uploadRequired);
    if (filesNotYetuploaded.isEmpty) return;
    log('${filesNotYetuploaded.length} file(s) require upload. triggering');
    await Future.wait(filesNotYetuploaded.map((e) => _upload(e.filePath)));
  }

  Future<void> upload(String filePath) async {
    final fileState = add(filePath);

    if (fileState.uploadRequired) {
      log('file(s) require upload. triggering');
      await _upload(fileState.filePath);
    }
  }

  Future<void> cancel(String filePath) async {
    state = Uploader({
      ...state.files,
      filePath: UploadState(
        filePath: filePath,
        uploadStatus: UploadStatus.ignore,
      ),
    });
  }

  void updateState({
    required String filePath,
    required UploadState uploadState,
  }) {
    if (state.files.keys.contains(filePath)) {
      state = Uploader({...state.files, filePath: uploadState});
    }
  }

  Future<void> _upload(String filePath) async {
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
    if (e != null) {
      log('$filePath: error: $e');
    }
    final updated = state.files[filePath]!.copyWith(
      serverResponse: () => null,
      uploadStatus: UploadStatus.error,
      entity: () => null,
      error: () => e ?? 'Empty response',
    );
    updateState(filePath: filePath, uploadState: updated);
  }

  void updateUploadPending(String filePath, String? e) {
    if (e != null) {
      log('$filePath: error: $e');
    }
    final updated = state.files[filePath]!.copyWith(
      serverResponse: () => null,
      uploadStatus: UploadStatus.pending,
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
    //log('$filePath: response: ${clEntity.label}');
    final updated = state.files[filePath]!.copyWith(
      serverResponse: () => response,
      uploadStatus: UploadStatus.success,
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
    //log('${task.filename}: ${result.status}');
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

    final pendingItems = state.files.values.where(
      (e) => e.uploadStatus != UploadStatus.ignore,
    );
    if (pendingItems.isEmpty) return;
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
        item.key: item.value.uploadStatus == UploadStatus.ignore
            ? item.value
            : item.value.copyWith(
                serverResponse: () => null,
                uploadStatus: UploadStatus.pending,
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

  UploadState? getStateByPath(String filePath) {
    return state.files[filePath];
  }

  void updateFaceRecgStatus(
    UploadState fileState,
    ActivityStatus faceRecgStatus,
  ) {
    final updated = state.files[fileState.filePath]!.copyWith(
      faceRecgStatus: faceRecgStatus,
    );
    updateState(filePath: fileState.filePath, uploadState: updated);
  }

  bool isScanReady(String filePath) {
    final fileState = getStateByPath(filePath);
    if (fileState == null) return false;
    final result = downloadPath != null && fileState.faceScanPossible;
    if (!result) {
      log('isScanReady: failed');
      log('isScanReady: uploadStatus = ${fileState.uploadStatus}');
      log('isScanReady: faceRecgStatus = ${fileState.faceRecgStatus}');
      log('isScanReady: downloadPath = $downloadPath');
    } else {
      log('isScanReady: $result');
    }
    return result;
  }

  bool isStillRequired(UploadState fileState, {bool forced = false}) {
    if (!forced) {
      final fileStateNow = getStateByPath(fileState.filePath);
      if (fileStateNow == null) {
        log('isStillRequired: false, reason: fileStateNow ==null');
        return false;
      }
      if (!fileStateNow.faceScanNeeded &&
          fileStateNow.faceRecgStatus != ActivityStatus.pending) {
        log(
          'isStillRequired: false, reason: fileStateNow.faceScanNeeded:${fileStateNow.faceScanNeeded}',
        );

        return false;
      }

      /// IF we had face already, even if it is empty
      /// we should skip
      final faces = ref.read(
        mediaListProvider.select((e) => e.getFaces(fileState.filePath)),
      );

      if (faces != null) {
        if (fileStateNow.faceRecgStatus != ActivityStatus.success) {
          log(
            'isStillRequired: faces found but faceRecgStatus is not set to success. Setting now.',
          );
          // There are faces, we don't need to force? review this logic while testing
          updateFaceRecgStatus(fileState, ActivityStatus.success);
        }
        log(
          'isStillRequired: false, reason: faces are already available: faces: $faces',
        );
        return false;
      }
    }
    updateFaceRecgStatus(fileState, ActivityStatus.processingNow);
    log('isStillRequired: true');
    return true;
  }

  Future<bool> scanForFace(UploadState fileState, {bool forced = false}) async {
    try {
      if (downloadPath != null && fileState.faceScanPossible) {
        if (fileState.entity!.label == null) {
          throw Exception(
            "state can't be marked as success when no identity was provided",
          );
        }
        updateFaceRecgStatus(fileState, ActivityStatus.pending);
        unawaited(
          ref
              .read(detectedFacesProvider.notifier)
              .scanImage(
                fileState.entity!.label!,
                downloadPath: downloadPath!,
                isStillRequired: () =>
                    isStillRequired(fileState, forced: forced),
              )
              .then((faceIds) {
                ref
                    .read(mediaListProvider.notifier)
                    .addFaces(fileState.filePath, faceIds);
                updateFaceRecgStatus(fileState, ActivityStatus.success);
              })
              .catchError((e) {
                updateFaceRecgStatus(fileState, ActivityStatus.error);
              }),
        );

        return true;
      }
      return false;
    } catch (e) {
      log('face scan aborted for ${fileState.filePath}');
      return false;
    }
  }

  Future<bool> scanForFaceByPath(String filePath, {bool forced = false}) async {
    // File is not yet uplaoded, return quitely
    final fileState = getStateByPath(filePath);
    if (fileState == null) return false;
    return scanForFace(fileState, forced: forced);
  }

  void faceRecgAllEligible() {
    final eligible = state.files.values.where((e) => e.faceScanNeeded);
    if (eligible.isEmpty) return;
    log(
      'faceRecgAllEligible: Found ${eligible.length} eligible files that require face Recg. triggering',
    );
    for (final fileState in eligible) {
      scanForFace(fileState);
    }
  }
}
