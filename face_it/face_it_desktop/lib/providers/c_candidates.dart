/* import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content_manager.dart/models/candidate.dart';
import '../content_manager.dart/providers/candidates.dart';
import 'b_candidate.dart';

final sessionCandidatesProvider =
    AsyncNotifierProvider<SessionCandidatesNotifier, List<Candidate>>(
      SessionCandidatesNotifier.new,
    );

class SessionCandidatesNotifier extends AsyncNotifier<List<Candidate>> {
  @override
  FutureOr<List<Candidate>> build() async {
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
      List<AsyncValue<Candidate>>
    >(SessionAsyncCandidatesNotifier.new);

class SessionAsyncCandidatesNotifier
    extends AsyncNotifier<List<AsyncValue<Candidate>>> {
  @override
  FutureOr<List<AsyncValue<Candidate>>> build() async {
    // Watch the list of IDs
    final files = ref.watch(candidatesProvider.select((e) => e.items));

    // Create an empty list to store the results
    final candidates = <AsyncValue<Candidate>>[];

    // Loop through each ID and watch the corresponding provider
    for (final file in files) {
      final candidate = ref.watch(sessionCandidateProvider(file));
      candidates.add(candidate);
    }

    return candidates;
  }
}
 */
