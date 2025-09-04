import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/selected_files.dart';

final sessionFilesProvider =
    StateNotifierProvider<SessionFilesNotifier, SelectedFiles>((ref) {
      return SessionFilesNotifier();
    });

class SessionFilesNotifier extends StateNotifier<SelectedFiles> {
  SessionFilesNotifier() : super(const SelectedFiles([]));
  void setActiveFile(String file) => state = state.setActiveFile(file);

  void append(List<XFile> files) => state = state.append(files);

  void remove(List<XFile> files) => state = state.remove(files);

  void removeByPath(List<String> pathsToRemove) =>
      state = state.removeByPath(pathsToRemove);
}
