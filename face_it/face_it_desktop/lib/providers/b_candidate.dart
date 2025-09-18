/* import 'dart:async';

import 'package:content_store/content_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../content_manager.dart/models/candidate.dart';

final sessionCandidateProvider =
    AsyncNotifierProviderFamily<SessionCandidateNotifier, Candidate, XFile>(
      SessionCandidateNotifier.new,
    );

class SessionCandidateNotifier extends FamilyAsyncNotifier<Candidate, XFile> {
  late String tempDirectory;
  @override
  FutureOr<Candidate> build(XFile arg) async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    tempDirectory = directories.temp.pathString;

    return Candidate(file: arg);
  }

  String? get identifier => state.value!.entity?.label;
}
 */
