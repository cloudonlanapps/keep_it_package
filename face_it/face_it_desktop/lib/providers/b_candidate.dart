import 'dart:async';
import 'dart:convert';

import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/models/cl_socket.dart';
import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/session_candidate.dart';
import 'd_session_provider.dart';
import 'f_faces.dart';
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

  Future<void> upload(CLServer server, CLSocket socket) async {
    if (state.value!.status != MediaStatus.added) {
      return;
    }
    state = AsyncData(state.value!.copyWith(status: MediaStatus.uploading));

    final result = await socket.uploadMedia(
      state.value!.file.path,
      onProgress: (progress) {
        state = AsyncData(
          state.value!.copyWith(
            uploadProgress: () => 'uploading ($progress %)',
          ),
        );
      },
    );
    if (result?.isNotEmpty ?? false) {
      try {
        final withEntity = state.value!.entityFromMap(
          jsonDecode(result!) as Map<String, dynamic>,
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
          .read(sessionProvider)
          .whenOrNull(data: (data) => data)
          ?.aitask(identifier!, 'recognize');
      if (response == null) return;
      final faces = <DetectedFace>[
        if (response['faces'] case final List<dynamic> facesList)
          ...facesList.map(
            (r) => DetectedFace.fromMap(r as Map<String, dynamic>),
          ),
      ];

      var entity = state.value!.entity!;
      if (response['dimension'] case [final int width, final int height]) {
        entity = entity.copyWith(width: () => width, height: () => height);
      }
      ref.read(detectedFacesProvider.notifier).upsertFaces(faces);

      state = AsyncData(
        state.value!.copyWith(
          faces: () => faces.map((e) => e.identity).toList(),
          entity: () => entity,
        ),
      );

      ref.read(messagesProvider.notifier).addMessage('$faces');
    }
  }
}
