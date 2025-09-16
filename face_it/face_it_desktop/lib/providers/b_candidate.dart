import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:content_store/content_store.dart';
import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/models/face/guessed_face.dart';
import 'package:face_it_desktop/models/face/registered_person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/session_candidate.dart';
import 'd_online_server.dart';
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
  late String tempDirectory;
  @override
  FutureOr<SessionCandidate> build(XFile arg) async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    tempDirectory = directories.temp.pathString;

    return SessionCandidate(file: arg);
  }

  Future<void> upload(CLServer server, String sessionId) async {
    if (state.value!.status != MediaStatus.added) {
      return;
    }
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
      state = AsyncData(state.value!.copyWith(isRecognizing: true));

      await Future.wait([
        () async {
          final response = await ref
              .read(sessionProvider.notifier)
              .aitask(identifier!, 'recognize');
          final List<DetectedFace> faces;
          if (response['faces'] case final List<dynamic> facesList) {
            faces = <DetectedFace>[];
            for (final map in facesList) {
              final face = await lookupOnStore(map as Map<String, dynamic>);
              if (face != null) faces.add(face);
            }
          } else {
            faces = [];
          }

          var entity = state.value!.entity!;
          if (response['dimension'] case [final int width, final int height]) {
            entity = entity.copyWith(width: () => width, height: () => height);
          }
          ref.read(detectedFacesProvider.notifier).upsertFaces(faces);

          state = AsyncData(
            state.value!.copyWith(
              faceIds: () => faces.map((e) => e.identity).toList(),
              entity: () => entity,
            ),
          );
          ref.read(messagesProvider.notifier).addMessage('$faces');
        }(),
        Future<void>.delayed(const Duration(seconds: 2)), // fixed wait
      ]);

      state = AsyncData(state.value!.copyWith(isRecognizing: false));
    }
  }

  Future<DetectedFace?> lookupOnStore(Map<String, dynamic> map) async {
    if (!map.containsKey('image')) {
      //('Unexpected response from server');
      return null;
    }
    final session = await ref.read(sessionProvider.future);
    final server = await ref.read(activeAIServerProvider.future);

    final identity = map['image'] as String;

    if (session?.connected ?? false) {
      //throw Exception('session is not connected');
      return null;
    }
    if (server == null) {
      //throw Exception('server is not available');
      return null;
    }

    final faceUrl = '/sessions/${session!.socket.id}/face/$identity';
    final vectorUrl = '/sessions/${session.socket.id}/vector/$identity';
    final faceFileName = p.join(tempDirectory, identity);
    final vectorFilename = p.join(
      tempDirectory,
      identity.replaceAll(RegExp(r'\.png$'), '.npy'),
    );

    final facePath = await server.downloadFile(faceUrl, faceFileName);
    final vectorPath = await server.downloadFile(vectorUrl, vectorFilename);
    if (facePath == null || vectorPath == null) return null;
    map['imageCache'] = facePath;
    map['vectorCache'] = vectorPath;

    final face = await searchDB(DetectedFace.fromMap(map), server);

    return face;
  }

  Future<DetectedFace> searchDB(DetectedFace face, CLServer server) async {
    final reply = await server.post(
      '/store/search',
      filesFields: {
        'vector': [face.vectorCache],
      },
    );
    return reply.when(
      validResponse: (result) async {
        final decoded = jsonDecode(result as String);

        if (decoded is! List) {
          throw ArgumentError('Expected a JSON list');
        }

        final map = {
          for (final item in decoded)
            if (item is Map &&
                item.containsKey('name') &&
                item.containsKey('confidence'))
              item['name'].toString(): (item['confidence'] as num).toDouble(),
        };

        final guesses = <GuessedPerson>[];
        for (final name in map.keys) {
          if (map[name]! > 0.5) {
            final personReply = await server.get('/store/person/$name');
            final person = await personReply.when(
              validResponse: (personJson) async {
                return RegisteredPerson.fromJson(personJson as String);
              },
              errorResponse: (e, {st}) async {
                return null;
              },
            );
            if (person != null) {
              guesses.add(
                GuessedPerson(person: person, confidence: map[name]!),
              );
            }
          }
        }

        if (guesses.isNotEmpty) {
          return face.copyWith(guesses: () => guesses);
        } else {
          return face;
        }
      },
      errorResponse: (e, {st}) async {
        return face;
      },
    );
  }
}
