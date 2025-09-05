import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/session_candidate.dart';

final sessionCandidateProvider =
    AsyncNotifierProviderFamily<
      SessionCandidateNotifier,
      SessionCandidate,
      XFile
    >(SessionCandidateNotifier.new);

class SessionCandidateNotifier
    extends FamilyAsyncNotifier<SessionCandidate, XFile> {
  @override
  FutureOr<SessionCandidate> build(XFile arg) async {
    return SessionCandidate(file: arg);
  }

  Future<void> upload(CLServer server, String sessionId) async {
    state = AsyncData(state.value!.copyWith(status: MediaStatus.uploading));
    final task = UploadTask.fromFile(
      file: File(state.value!.file.path),
      url:
          '${server.storeURL.uri.replace(port: 5002)}/sessions/$sessionId/upload',

      fileField: 'media',
      updates: Updates.progress, // request status and progress updates
    );
    final result = await FileDownloader().upload(
      task,
      onProgress: (progress) {
        state = AsyncData(
          state.value!.copyWith(
            uploadProgress: () => 'uploading ($progress %)',
          ),
        );
      },
    );
    if (result.responseBody?.isNotEmpty ?? false) {
      final withEntity = state.value!.entityFromMap(
        jsonDecode(result.responseBody!) as Map<String, dynamic>,
      );
      state = AsyncData(
        withEntity.copyWith(
          uploadProgress: () => null,
          status: MediaStatus.uploaded,
        ),
      );
    } else {
      state = AsyncData(
        state.value!.copyWith(uploadProgress: () => 'file upload failed'),
      );
    }
  }
}
