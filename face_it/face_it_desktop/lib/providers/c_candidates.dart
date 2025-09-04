import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_candidate.dart';
import 'a_files.dart';
import 'b_candidate.dart';

final sessionCandidatesProvider =
    AsyncNotifierProvider<SessionCandidatesNotifier, List<SessionCandidate>>(
      SessionCandidatesNotifier.new,
    );

class SessionCandidatesNotifier extends AsyncNotifier<List<SessionCandidate>> {
  @override
  FutureOr<List<SessionCandidate>> build() async {
    final asyncCandidates = await ref.watch(
      sessionAsyncCandidatesProvider.future,
    );

    final candidates = asyncCandidates
        .where((userAsyncValue) => userAsyncValue.hasValue)
        .map((userAsyncValue) => userAsyncValue.value!)
        .toList();

    return candidates;
  }
}

final sessionAsyncCandidatesProvider =
    AsyncNotifierProvider<
      SessionAsyncCandidatesNotifier,
      List<AsyncValue<SessionCandidate>>
    >(SessionAsyncCandidatesNotifier.new);

class SessionAsyncCandidatesNotifier
    extends AsyncNotifier<List<AsyncValue<SessionCandidate>>> {
  @override
  FutureOr<List<AsyncValue<SessionCandidate>>> build() async {
    // Watch the list of IDs
    final files = ref.watch(sessionFilesProvider.select((e) => e.files));

    // Create an empty list to store the results
    final candidates = <AsyncValue<SessionCandidate>>[];

    // Loop through each ID and watch the corresponding provider
    for (final file in files) {
      final candidate = ref.watch(sessionCandidateProvider(file));
      candidates.add(candidate);
    }

    return candidates;
  }
}
