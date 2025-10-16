import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/media_list.dart';

final mediaListProvider =
    StateNotifierProvider<MediaListNotifier, MediaListModel>((ref) {
      return MediaListNotifier();
    });

class MediaListNotifier extends StateNotifier<MediaListModel> {
  MediaListNotifier() : super(const MediaListModel([]));
  final List<XFile> files = [];
  void setActiveFile(String file) => state = state.setActiveFile(file);

  void append(List<XFile> files) {
    this.files.addAll(files);
    unawaited(addSlowly());
  }

  Future<void> addSlowly() async {
    if (files.isEmpty) return;
    while (files.isNotEmpty) {
      final file = files.removeAt(0);
      state = state.append([file]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  void removeByPath(List<String> pathsToRemove) =>
      state = state.removeByPath(pathsToRemove);
  void clear() => state = const MediaListModel([]);
}
