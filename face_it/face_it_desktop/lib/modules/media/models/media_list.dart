import 'package:cl_basic_types/cl_basic_types.dart' show ValueGetter;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:image_picker/image_picker.dart';

import 'media.dart';

/// Maintains the list of files provided by user.
/// user can add or remove the files
/// duplicates are ignored.

@immutable
class MediaListModel {
  const MediaListModel(this.mediaList, {this.activeMediaId});
  final List<MediaModel> mediaList;
  final String? activeMediaId;

  MediaListModel copyWith({
    List<MediaModel>? mediaList,
    ValueGetter<String?>? activeMediaId,
  }) {
    return MediaListModel(
      mediaList ?? this.mediaList,
      activeMediaId: activeMediaId != null
          ? activeMediaId.call()
          : this.activeMediaId,
    );
  }

  @override
  bool operator ==(covariant MediaListModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.mediaList, mediaList) &&
        other.activeMediaId == activeMediaId;
  }

  @override
  int get hashCode => mediaList.hashCode ^ activeMediaId.hashCode;

  MediaModel? get activeFile => activeMediaId == null
      ? null
      : mediaList.where((item) => item.file.path == activeMediaId).firstOrNull;

  MediaListModel setActiveFile(String? value) {
    if (value == null) {
      return copyWith(activeMediaId: () => null);
    }
    final activeFileUpdated = mediaList
        .where((e) => e.file.path == value)
        .firstOrNull
        ?.file
        .path;
    return copyWith(activeMediaId: () => activeFileUpdated);
  }

  MediaListModel append(List<XFile> newFiles) {
    final uniqueImages = newFiles
        .map((file) => MediaModel(file: file))
        .where((e) => !mediaList.map((c) => c.file.path).contains(e.file.path));
    final filesUpdated = [...mediaList, ...uniqueImages];

    final activeFileUpdated = filesUpdated
        .where((e) => e.file.path == activeMediaId)
        .firstOrNull
        ?.file
        .path;

    return copyWith(
      mediaList: filesUpdated,
      activeMediaId: () => activeFileUpdated,
    );
  }

  MediaListModel removeByPath(List<String> pathsToRemove) {
    final filesUpdated = mediaList
        .where((e) => !pathsToRemove.contains(e.file.path))
        .toList();

    final activeFileUpdated = filesUpdated
        .where((e) => e.file.path == activeMediaId)
        .firstOrNull
        ?.file
        .path;

    return copyWith(
      mediaList: filesUpdated,
      activeMediaId: () => activeFileUpdated,
    );
  }

  MediaModel? itemByPath(String path) =>
      mediaList.where((item) => item.file.path == path).firstOrNull;

  MediaModel? get activeCandidate {
    if (activeMediaId == null) {
      return null;
    } else {
      return itemByPath(activeMediaId!);
    }
  }

  List<String>? getFaces(String pathIdentity) =>
      mediaList.where((e) => e.file.path == pathIdentity).firstOrNull?.faceIds;

  MediaListModel addFaces(String pathIdentity, List<String> faceIds) {
    return copyWith(
      mediaList: [
        ...mediaList.map(
          (e) => e.file.path == pathIdentity
              ? e.copyWith(faceIds: () => faceIds)
              : e,
        ),
      ],
    );
  }
}
