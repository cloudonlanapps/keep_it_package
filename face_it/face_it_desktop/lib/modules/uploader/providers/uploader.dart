import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart' show detectedFacesProvider;
import 'package:content_store/content_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../server/providers/upload_url_provider.dart';
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

  Iterable<String> addMultiple(Iterable<String> filePaths) {
    if (filePaths.isNotEmpty) {
      final updatedFiles = <String, UploadState>{};

      for (final filePath in filePaths) {
        if (!state.files.containsKey(filePath)) {
          updatedFiles[filePath] = UploadState(filePath: filePath);
        } else if (getFileState(filePath)!.uploadStatus ==
            UploadStatus.ignore) {
          updatedFiles[filePath] = getFileState(
            filePath,
          )!.copyWith(uploadStatus: UploadStatus.pending);
        }
      }

      if (updatedFiles.isNotEmpty) {
        state = Uploader({...state.files, ...updatedFiles});
      }
    }

    return filePaths
        .map((e) => state.files[e]!)
        .where((e) => e.uploadPending)
        .map((e) => e.filePath);
  }

  Future<void> uploadMultiple(Iterable<String> filePaths) async {
    if (filePaths.isEmpty) {
      return;
    }
    final files = addMultiple(filePaths);
    if (files.isNotEmpty) {
      log('${files.length} file(s) require upload. triggering');
      await Future.wait(files.map(_upload));
    }
  }

  String? add(String filePath) {
    return addMultiple([filePath]).firstOrNull;
  }

  Future<void> upload(String filePath) async {
    final file = add(filePath);

    if (file != null) {
      log('file $filePath require upload. triggering');
      await _upload(file);
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
    if (state.files.keys.contains(filePath) &&
        getFileState(filePath) != uploadState) {
      log('updateState: $filePath: $uploadState');
      state = Uploader({...state.files, filePath: uploadState});
    } else {
      log('updateState: $filePath:state update deferred as no change');
    }
  }

  Future<void> _upload(String filePath) async {
    final fileName = p.basename(filePath);
    final logPrefix = '_upload $fileName:';
    final uploader = state;

    log('$logPrefix Request Received');

    if (!uploader.files.keys.contains(filePath)) {
      log('$logPrefix fileState not found');
      return;
    }
    final fileState = getFileState(filePath)!;

    if (!fileState.uploadPending) {
      log('$logPrefix File already uploaded, reset to retry, use force');
    }

    final url = ref.read(uploadURLProvider);
    if (url == null) {
      log('$logPrefix unable to start the upload as network not found');
      return;
    }
    updateState(
      filePath: filePath,
      uploadState: fileState.setUploadStatusUploading,
    );

    log('$logPrefix startUpload called in async mode');
    unawaited(
      BackgroundDownloaderWrap.startUpload(
        filePath,
        url,
        onUpdateProgress: cbUpdateProgress,
        onUpdateStatus: cbUpdateStatus,
        onUploadError: cbUploadError,
        onUploadCompleted: onUploadCompleted,
        onReset: onReset,
      ),
    );
  }

  void onReset(String filePath) {
    updateState(filePath: filePath, uploadState: getFileState(filePath)!.reset);
  }

  void onUploadCompleted(
    String filePath,
    String identity,
    Map<String, dynamic> map,
  ) {
    final fileState = getFileState(filePath);
    if (fileState == null) return;
    final url = ref.read(uploadURLProvider);
    if (url == null) {
      return onReset(filePath);
    }
    updateState(
      filePath: filePath,
      uploadState: fileState.setIdentity(identity, map),
    );
  }

  void cbUploadError(String filePath, String error) {
    final fileState = getFileState(filePath);
    if (fileState == null) return;
    final url = ref.read(uploadURLProvider);
    if (url == null) {
      return onReset(filePath);
    }
    updateState(
      filePath: filePath,
      uploadState: fileState.setUploadError(error),
    );
  }

  void cbUpdateStatus(String filePath, TaskStatus status) {
    final fileState = getFileState(filePath);
    if (fileState == null) return;
    final url = ref.read(uploadURLProvider);
    if (url != null) {
      updateState(filePath: filePath, uploadState: fileState.setStatus(status));
    }
  }

  void cbUpdateProgress(String filePath, double progress) {
    final fileState = getFileState(filePath);
    if (fileState == null) return;
    final url = ref.read(uploadURLProvider);
    if (url != null) {
      updateState(
        filePath: filePath,
        uploadState: fileState.setProgress(progress),
      );
    }
  }

  Future<void> retryNew() async {
    final url = ref.read(uploadURLProvider);
    if (url == null) return;
    log('retry: valid url found (url: $url)');
    log(state.currentStatus);
    final pendingItems = state.files.values.where((e) => e.uploadPending);
    if (pendingItems.isEmpty) return;
    log('retry ${pendingItems.length} pendingItems');

    for (final item in pendingItems) {
      log('retry ${item.filePath}: invoke _upload');
      await _upload(item.filePath);
    }
  }

  Future<void> resetNew() async {
    await cancelAllTasks();
    final items = <String, UploadState>{};
    for (final item in state.files.entries) {
      items[item.key] = item.value.uploadStatus == UploadStatus.ignore
          ? item.value
          : item.value.reset;
      log(
        'reset ${item.value.filePath}: status reset to ${items[item.key]!.uploadStatus} ',
      );
    }
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

  UploadState? getFileState(String filePath) {
    return state.files[filePath];
  }

  void updateFaceRecgStatus(
    UploadState fileState,
    ActivityStatus faceRecgStatus, {
    List<String>? faces,
  }) {
    if (faceRecgStatus == ActivityStatus.success && faces == null) {
      throw Exception(
        'faces must be provided when successed. if no face, pass empty list',
      );
    }
    final updated = state.files[fileState.filePath]!.copyWith(
      faceRecgStatus: faceRecgStatus,
      faces: () => faces,
    );
    updateState(filePath: fileState.filePath, uploadState: updated);
  }

  bool isScanReady(String filePath) {
    final fileState = getFileState(filePath);
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
      final fileStateNow = getFileState(fileState.filePath);
      if (fileStateNow == null) {
        log('isStillRequired: false, reason: fileStateNow ==null');
        return false;
      }
      if (fileStateNow.faceRecgStatus != ActivityStatus.pending) {
        log(
          'isStillRequired: false, reason: faceRecgStatus:${fileStateNow.faceRecgStatus}',
        );

        return false;
      }

      /// IF we had face already, even if it is empty
      /// we should skip
      final faces = fileStateNow.faces;

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
        updateFaceRecgStatus(fileState, ActivityStatus.pending);
        unawaited(
          ref
              .read(detectedFacesProvider.notifier)
              .scanImage(
                fileState.identity!,
                downloadPath: downloadPath!,
                isStillRequired: () =>
                    isStillRequired(fileState, forced: forced),
              )
              .then((faceIds) {
                updateFaceRecgStatus(
                  fileState,
                  ActivityStatus.success,
                  faces: faceIds,
                );
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
    final fileState = getFileState(filePath);
    if (fileState == null) return false;
    return scanForFace(fileState, forced: forced);
  }

  void faceRecgAllEligible() {
    final eligible = state.files.values.where((e) {
      return e.uploadStatus == UploadStatus.success &&
          e.faceRecgStatus == ActivityStatus.premature;
    });
    if (eligible.isEmpty) return;
    log(
      'faceRecgAllEligible: Found ${eligible.length} eligible files that require face Recg. triggering',
    );
    for (final fileState in eligible) {
      scanForFace(fileState);
    }
  }
}

class BackgroundDownloaderWrap {
  static Future<void> startUpload(
    String filePath,
    String url, {
    required void Function(String filePath, double progress) onUpdateProgress,
    required void Function(String filePath, TaskStatus status) onUpdateStatus,
    required void Function(String filePath, String error) onUploadError,
    required void Function(String filePath) onReset,
    required void Function(
      String filePath,
      String identity,
      Map<String, dynamic> map,
    )
    onUploadCompleted,
    void Function(String msg)? log,
  }) async {
    final fileName = p.basename(filePath);
    final logPrefix = 'uploader $fileName:';
    final task = UploadTask.fromFile(
      file: File(filePath),
      url: url,
      fileField: 'media',
      updates: Updates.statusAndProgress,
    );

    log?.call('$logPrefix Enqueue the task');

    await FileDownloader()
        .upload(
          task,

          onProgress: (progress) {
            log?.call('$logPrefix progress $progress');
            onUpdateProgress(filePath, progress);
          },
          onStatus: (status) {
            log?.call('$logPrefix status $status');
            onUpdateStatus(filePath, status);
          },
        )
        .catchError((dynamic e) async {
          log?.call('$logPrefix catchError: Exception $e');

          return TaskStatusUpdate(task, TaskStatus.failed, TaskException('$e'));
        })
        .then((result) {
          switch (result.status) {
            case TaskStatus.enqueued:
            case TaskStatus.running:
            case TaskStatus.notFound:
            case TaskStatus.waitingToRetry:
            case TaskStatus.paused:
              log?.call('$logPrefix Unexpected, returning non finite state');
              throw Exception('returned a non finite state');
            case TaskStatus.failed:
              log?.call('$logPrefix failed, ${result.exception}');
              onUploadError(filePath, '${result.exception}');
            case TaskStatus.canceled:
              log?.call('$logPrefix cancelled');
              onReset(filePath);
            case TaskStatus.complete:
              final response = result.responseBody;
              if (response == null) {
                log?.call('$logPrefix failed, null response');
                onUploadError(filePath, 'Null Response');
              } else if (response.isEmpty) {
                log?.call('$logPrefix failed, empty response');
                onUploadError(
                  filePath,
                  '${result.exception ?? 'Empty Response'}',
                );
              } else {
                try {
                  final map = jsonDecode(response);
                  final identity =
                      (map as Map<String, dynamic>?)?['file_identifier']
                          as String?;
                  if (identity == null) {
                    return onUploadError(filePath, 'missing identity');
                  }
                  onUploadCompleted(filePath, identity, map!);
                } catch (e) {
                  return onUploadError(
                    filePath,
                    'invalid response from server',
                  );
                }
              }
          }
        });
  }
}
