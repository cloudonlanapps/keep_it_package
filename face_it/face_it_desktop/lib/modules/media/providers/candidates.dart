import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/media_list.dart';

final mediaListProvider =
    StateNotifierProvider<MediaListNotifier, MediaListModel>((ref) {
      return MediaListNotifier();
    });

class MediaListNotifier extends StateNotifier<MediaListModel> {
  MediaListNotifier() : super(const MediaListModel([]));
  void setActiveFile(String file) => state = state.setActiveFile(file);

  void append(List<XFile> files) => state = state.append(files);

  void removeByPath(List<String> pathsToRemove) =>
      state = state.removeByPath(pathsToRemove);
  void clear() => state = const MediaListModel([]);
}
