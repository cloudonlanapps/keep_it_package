import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/candidates.dart';

final candidatesProvider =
    StateNotifierProvider<CandidatesNotifier, Candidates>((ref) {
      return CandidatesNotifier();
    });

class CandidatesNotifier extends StateNotifier<Candidates> {
  CandidatesNotifier() : super(const Candidates([]));
  void setActiveFile(String file) => state = state.setActiveFile(file);

  void append(List<XFile> files) => state = state.append(files);

  void removeByPath(List<String> pathsToRemove) =>
      state = state.removeByPath(pathsToRemove);
  void clear() => state = const Candidates([]);
}
