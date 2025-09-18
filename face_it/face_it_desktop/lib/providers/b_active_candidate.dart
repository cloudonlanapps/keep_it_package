/* import 'package:face_it_desktop/content_manager.dart/providers/candidates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content_manager.dart/models/candidate.dart';
import 'b_candidate.dart';

final activeCandidateProvider = StateProvider<Candidate?>((ref) {
  final activeFile = ref.watch(candidatesProvider.select((e) => e.activeFile));

  final activeCandidate =
      (activeFile == null
              ? null
              : ref.watch(sessionCandidateProvider(activeFile)))
          ?.whenOrNull(data: (data) => data);
  return activeCandidate;
});
 */
