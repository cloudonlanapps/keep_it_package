import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:content_store/content_store.dart';
import 'package:face_it_desktop/models/face/f_face_file_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/face/registered_face.dart';
import 'd_online_server.dart';
import 'd_session_provider.dart';
import 'f_face.dart';
import 'f_faces.dart';

final faceFileCacheProvider =
    AsyncNotifierProviderFamily<FaceFileCacheNotifier, FaceFileCache?, String>(
      FaceFileCacheNotifier.new,
    );

class FaceFileCacheNotifier
    extends FamilyAsyncNotifier<FaceFileCache?, String> {
  late String tempDirectory;

  @override
  FutureOr<FaceFileCache?> build(String arg) async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    tempDirectory = directories.temp.pathString;

    final server = await ref.watch(activeAIServerProvider.future);
    if (server == null) return null;
    final session = await ref.watch(sessionProvider.future);
    if (session?.connected ?? false) return null;

    final face = await ref.watch(detectedFaceProvider(arg).future);
    if (face == null) return null;
    final faceUrl = '/sessions/${session!.socket.id}/face/${face.identity}';
    final vectorUrl = '/sessions/${session.socket.id}/vector/${face.identity}';
    final faceFileName = p.join(tempDirectory, face.identity);
    final vectorFilename = p.join(
      tempDirectory,
      face.identity.replaceAll(RegExp(r'\.png$'), '.npy'),
    );

    final facePath = await server.downloadFile(faceUrl, faceFileName);
    final vectorPath = await server.downloadFile(vectorUrl, vectorFilename);

    if (facePath == null || vectorPath == null) return null;

    return FaceFileCache(face: face, image: facePath, vector: vectorPath);
  }
}
