import 'package:face_it_desktop/providers/a_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_candidate.dart';
import 'b_candidate.dart';

final activeCandidateProvider = StateProvider<SessionCandidate?>((ref) {
  final activeFile = ref.watch(
    sessionFilesProvider.select((e) => e.activeFile),
  );

  final activeCandidate =
      (activeFile == null
              ? null
              : ref.watch(sessionCandidateProvider(activeFile)))
          ?.whenOrNull(data: (data) => data);
  return activeCandidate;
});
