import 'package:cl_basic_types/cl_basic_types.dart' show ValueGetter;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:image_picker/image_picker.dart';

/// Maintains the list of files provided by user.
/// user can add or remove the files
/// duplicates are ignored.

@immutable
class SelectedFiles {
  const SelectedFiles(this.files, {this.activeFilePath});
  final List<XFile> files;
  final String? activeFilePath;

  SelectedFiles copyWith({
    List<XFile>? files,
    ValueGetter<String?>? activeFile,
  }) {
    return SelectedFiles(
      files ?? this.files,
      activeFilePath: activeFile != null ? activeFile.call() : activeFilePath,
    );
  }

  @override
  bool operator ==(covariant SelectedFiles other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.files, files) &&
        other.activeFilePath == activeFilePath;
  }

  @override
  int get hashCode => files.hashCode ^ activeFilePath.hashCode;

  XFile? get activeFile => activeFilePath == null
      ? null
      : files.where((file) => file.path == activeFilePath).firstOrNull;

  SelectedFiles setActiveFile(String? value) {
    if (value == null) {
      return copyWith(activeFile: () => null);
    }
    final activeFileUpdated = files
        .where((e) => e.path == value)
        .firstOrNull
        ?.path;
    return copyWith(activeFile: () => activeFileUpdated);
  }

  SelectedFiles append(List<XFile> newFiles) {
    final uniqueImages = newFiles.where(
      (e) => !files.map((c) => c.path).contains(e.path),
    );
    final filesUpdated = [...files, ...uniqueImages];

    final activeFileUpdated = filesUpdated
        .where((e) => e.path == activeFilePath)
        .firstOrNull
        ?.path;

    return copyWith(files: filesUpdated, activeFile: () => activeFileUpdated);
  }

  SelectedFiles remove(List<XFile> files) {
    final pathsToRemove = files.map((e) => e.path);
    final filesUpdated = files
        .where((e) => !pathsToRemove.contains(e.path))
        .toList();

    final activeFileUpdated = filesUpdated
        .where((e) => e.path == activeFilePath)
        .firstOrNull
        ?.path;

    return copyWith(files: filesUpdated, activeFile: () => activeFileUpdated);
  }

  SelectedFiles removeByPath(List<String> pathsToRemove) {
    final filesUpdated = files
        .where((e) => !pathsToRemove.contains(e.path))
        .toList();

    final activeFileUpdated = filesUpdated
        .where((e) => e.path == activeFilePath)
        .firstOrNull
        ?.path;

    return copyWith(files: filesUpdated, activeFile: () => activeFileUpdated);
  }
}
