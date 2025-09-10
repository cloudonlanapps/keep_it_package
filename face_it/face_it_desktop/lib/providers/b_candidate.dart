import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/models/face.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/session_candidate.dart';
import 'd_session_provider.dart';
import 'messages.dart';

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
      url: '${server.storeURL.uri}/sessions/$sessionId/upload',

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
      try {
        final withEntity = state.value!.entityFromMap(
          jsonDecode(result.responseBody!) as Map<String, dynamic>,
        );
        state = AsyncData(
          withEntity.copyWith(
            uploadProgress: () => null,
            status: MediaStatus.uploaded,
          ),
        );
      } catch (e) {
        state = AsyncData(
          state.value!.copyWith(uploadProgress: () => 'file upload failed'),
        );
      }
    } else {
      state = AsyncData(
        state.value!.copyWith(uploadProgress: () => 'file upload failed'),
      );
    }
  }

  String? get identifier => state.value!.entity?.label;
  Future<void> recognize() async {
    if (state.value!.isUploaded) {
      final response = await ref
          .read(sessionProvider.notifier)
          .aitask(identifier!, 'recognize');
      print(response);
      final faces = <Face>[
        if (response['faces'] case final List<dynamic> facesList)
          ...facesList.map((r) => Face.fromMap(r as Map<String, dynamic>)),
      ];

      var entity = state.value!.entity!;
      if (response['dimension'] case [final int width, final int height]) {
        entity = entity.copyWith(width: () => width, height: () => height);
      }

      state = AsyncData(
        state.value!.copyWith(faces: () => faces, entity: () => entity),
      );

      ref.read(messagesProvider.notifier).addMessage('$faces');
    }
  }
}
