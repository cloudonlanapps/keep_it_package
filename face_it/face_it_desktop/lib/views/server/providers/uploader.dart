import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/views/server/models/upload_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_state.dart';
import '../models/uploader.dart';

final uploaderProvider = AsyncNotifierProvider<UploaderNotifier, Uploader>(
  UploaderNotifier.new,
);

class UploaderNotifier extends AsyncNotifier<Uploader> {
  @override
  FutureOr<Uploader> build() {
    return const Uploader({});
  }

  void upsert({required String filePath, required UploadState uploadState}) {
    state = AsyncValue.data(
      Uploader({...state.value!.files, filePath: uploadState}),
    );
  }

  Future<void> _upload(
    String filePath, {
    required ServerPreferences pref,
  }) async {
    if (state.value!.files[filePath]?.status == UploadStatus.success ||
        state.value!.files[filePath]?.status == UploadStatus.uploading) {
      // avoid redundent upload.
      return;
    }
    CLSocket? session;
    CLServer? server;
    session = ref
        .read(socketConnectionProvider(pref))
        .whenOrNull(data: (data) => data.socket.connected ? data : null);
    server = ref
        .read(activeAIServerProvider(pref))
        .whenOrNull(data: (data) => (data?.connected ?? false) ? data : null);
    if (session == null || server == null) {
      final updated = state.value!.files[filePath]!.copyWith(
        serverResponse: () => null,
        status: UploadStatus.pending,
        entity: () => null,
        error: () => server == null ? 'Server not found' : 'No Session running',
      );
      upsert(filePath: filePath, uploadState: updated);
      return;
    }
    final uploader = state.value!;

    if (!uploader.files.keys.contains(filePath)) {
      return;
    }

    final task = UploadTask.fromFile(
      file: File(state.value!.files[filePath]!.filePath),
      url: '${server.storeURL.uri}/sessions/${session.socket.id}/upload',
      fileField: 'media',
      updates: Updates.progress, // request status and progress updates
    );

    unawaited(
      FileDownloader()
          .upload(
            task,
            onProgress: (progress) {
              final updated = state.value!.files[filePath]!.copyWith(
                serverResponse: () => '${(progress * 100).toStringAsFixed(1)}%',
              );
              upsert(filePath: filePath, uploadState: updated);
            },
          )
          .then((result) {
            if (result.responseBody?.isNotEmpty ?? false) {
              try {
                final clEntity = UploadState.entityFromMap(
                  jsonDecode(result.responseBody!) as Map<String, dynamic>,
                );
                final updated = state.value!.files[filePath]!.copyWith(
                  serverResponse: () => result.responseBody!,
                  status: UploadStatus.success,
                  entity: () => clEntity,
                  error: () => null,
                );
                upsert(filePath: filePath, uploadState: updated);
              } catch (e) {
                final updated = state.value!.files[filePath]!.copyWith(
                  serverResponse: () => null,
                  status: UploadStatus.error,
                  entity: () => null,
                  error: e.toString,
                );
                upsert(filePath: filePath, uploadState: updated);
              }
            } else {
              final updated = state.value!.files[filePath]!.copyWith(
                serverResponse: () => null,
                status: UploadStatus.error,
                entity: () => null,
                error: () => 'Empty response',
              );
              upsert(filePath: filePath, uploadState: updated);
            }
          }),
    );
  }

  Future<void> upload(
    String filePath, {
    required ServerPreferences pref,
  }) async {
    if (!state.value!.files.keys.contains(filePath)) {
      final newItem = UploadState(filePath: filePath);
      upsert(
        filePath: filePath,
        uploadState: newItem.copyWith(status: UploadStatus.pending),
      );
    }

    await _upload(filePath, pref: pref);
  }

  Future<void> retry(ServerPreferences pref) async {
    final pendingItems = state.value!.files.values.where(
      (e) => e.status == UploadStatus.pending || e.status == UploadStatus.error,
    );
    for (final item in pendingItems) {
      await _upload(item.filePath, pref: pref);
    }
  }
}
