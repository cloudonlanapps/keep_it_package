import 'dart:async';

import 'package:content_store/content_store.dart';
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
  late String tempDirectory;
  @override
  FutureOr<SessionCandidate> build(XFile arg) async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    tempDirectory = directories.temp.pathString;

    return SessionCandidate(file: arg);
  }

  String? get identifier => state.value!.entity?.label;
}
