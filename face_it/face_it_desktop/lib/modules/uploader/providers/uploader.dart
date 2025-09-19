import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_state.dart';
import '../models/upload_status.dart';
import '../models/uploader.dart';

final uploaderProvider = StateNotifierProvider<UploaderNotifier, Uploader>(
  (ref) => UploaderNotifier(),
);

class UploaderNotifier extends StateNotifier<Uploader> with CLLogger {
  UploaderNotifier() : super(const Uploader({}));
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

  Future<void> uploadMultiple(Iterable<String> filePaths, String? url) async {
    if (filePaths.isEmpty) {
      return;
    }
    final files = addMultiple(filePaths);
    if (url == null) return;
    await Future.wait(files.map((e) => _upload(e, url)));
  }

  Future<void> upload(String filePath, String url) async {
    await _upload(add(filePath), url);
  }

  void updateState({
    required String filePath,
    required UploadState uploadState,
  }) {
    state = Uploader({...state.files, filePath: uploadState});
  }

  Future<void> _upload(String filePath, String url) async {
    if (state.files[filePath]?.status == UploadStatus.success ||
        state.files[filePath]?.status == UploadStatus.uploading) {
      // avoid redundent upload.
      return;
    }

    final uploader = state;

    if (!uploader.files.keys.contains(filePath)) {
      return;
    }

    final task = UploadTask.fromFile(
      file: File(state.files[filePath]!.filePath),
      url: url,
      fileField: 'media',
      updates: Updates.progress, // request status and progress updates
    );

    unawaited(
      FileDownloader()
          .upload(
            task,
            onProgress: (progress) {
              final updated = state.files[filePath]!.copyWith(
                serverResponse: () => '${(progress * 100).toStringAsFixed(1)}%',
              );
              updateState(filePath: filePath, uploadState: updated);
            },
          )
          .then((result) {
            if (result.responseBody?.isNotEmpty ?? false) {
              try {
                final clEntity = UploadState.entityFromMap(
                  jsonDecode(result.responseBody!) as Map<String, dynamic>,
                );
                final updated = state.files[filePath]!.copyWith(
                  serverResponse: () => result.responseBody!,
                  status: UploadStatus.success,
                  entity: () => clEntity,
                  error: () => null,
                );
                updateState(filePath: filePath, uploadState: updated);
              } catch (e) {
                final updated = state.files[filePath]!.copyWith(
                  serverResponse: () => null,
                  status: UploadStatus.error,
                  entity: () => null,
                  error: e.toString,
                );
                updateState(filePath: filePath, uploadState: updated);
              }
            } else {
              final updated = state.files[filePath]!.copyWith(
                serverResponse: () => null,
                status: UploadStatus.error,
                entity: () => null,
                error: () => 'Empty response',
              );
              updateState(filePath: filePath, uploadState: updated);
            }
          }),
    );
  }

  Future<void> retryNew(String url) async {
    final pendingItems = state.files.values.where(
      (e) => e.status == UploadStatus.pending || e.status == UploadStatus.error,
    );
    log(
      'resetting ${pendingItems.length} pendingItems in state (has ${state.files.length}) items',
    );
    for (final item in pendingItems) {
      await _upload(item.filePath, url);
    }
  }

  Future<void> resetNew() async {
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
}
