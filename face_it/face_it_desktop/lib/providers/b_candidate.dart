import 'dart:async';

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
    return SessionCandidate(path: arg.path, label: arg.name);
  }
}
