import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/views/server/models/upload_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_state.dart';
import '../models/uploader.dart';

final uploaderProvider =
    AsyncNotifierProviderFamily<UploaderNotifier, Uploader, ServerPreferences>(
      UploaderNotifier.new,
    );

class UploaderNotifier
    extends FamilyAsyncNotifier<Uploader, ServerPreferences> {
  CLSocket? session;
  CLServer? server;
  @override
  FutureOr<Uploader> build(ServerPreferences args) {
    session = ref
        .watch(socketConnectionProvider(args))
        .whenOrNull(data: (data) => data.socket.connected ? data : null);
    server = ref
        .watch(activeAIServerProvider(args))
        .whenOrNull(data: (data) => (data?.connected ?? false) ? data : null);
    return const Uploader({});
  }

  void upsert({required String filePath, required UploadState uploadState}) {
    state = AsyncValue.data(
      Uploader({...state.value!.files, filePath: uploadState}),
    );
  }

  Future<void> upload({required String filePath}) async {
    if (server == null || session == null) {
      return;
    }
    final uploader = state.value!;

    if (uploader.files.keys.contains(filePath)) {
      return;
    }
    final newItem = UploadState(filePath: filePath);
    upsert(
      filePath: filePath,
      uploadState: newItem.copyWith(status: UploadStatus.uploading),
    );
    final task = UploadTask.fromFile(
      file: File(newItem.filePath),
      url: '${server!.storeURL.uri}/sessions/${session!.socket.id}/upload',
      fileField: 'media',
      updates: Updates.progress, // request status and progress updates
    );

    final result = await FileDownloader().upload(
      task,
      onProgress: (progress) {
        final updated = state.value!.files[filePath]!.copyWith(
          serverResponse: () => '${(progress * 100).toStringAsFixed(1)}%',
        );
        upsert(filePath: filePath, uploadState: updated);
      },
    );
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
  }
}
