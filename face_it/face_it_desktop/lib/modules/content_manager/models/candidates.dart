import 'package:cl_basic_types/cl_basic_types.dart' show ValueGetter;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:image_picker/image_picker.dart';

import 'candidate.dart';

/// Maintains the list of files provided by user.
/// user can add or remove the files
/// duplicates are ignored.

@immutable
class Candidates {
  const Candidates(this.items, {this.activeFilePath});
  final List<Candidate> items;
  final String? activeFilePath;

  Candidates copyWith({
    List<Candidate>? files,
    ValueGetter<String?>? activeFile,
  }) {
    return Candidates(
      files ?? items,
      activeFilePath: activeFile != null ? activeFile.call() : activeFilePath,
    );
  }

  @override
  bool operator ==(covariant Candidates other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) &&
        other.activeFilePath == activeFilePath;
  }

  @override
  int get hashCode => items.hashCode ^ activeFilePath.hashCode;

  Candidate? get activeFile => activeFilePath == null
      ? null
      : items.where((item) => item.file.path == activeFilePath).firstOrNull;

  Candidates setActiveFile(String? value) {
    if (value == null) {
      return copyWith(activeFile: () => null);
    }
    final activeFileUpdated = items
        .where((e) => e.file.path == value)
        .firstOrNull
        ?.file
        .path;
    return copyWith(activeFile: () => activeFileUpdated);
  }

  Candidates append(List<XFile> newFiles) {
    final uniqueImages = newFiles
        .map((file) => Candidate(file: file))
        .where((e) => !items.map((c) => c.file.path).contains(e.file.path));
    final filesUpdated = [...items, ...uniqueImages];

    final activeFileUpdated = filesUpdated
        .where((e) => e.file.path == activeFilePath)
        .firstOrNull
        ?.file
        .path;

    return copyWith(files: filesUpdated, activeFile: () => activeFileUpdated);
  }

  Candidates removeByPath(List<String> pathsToRemove) {
    final filesUpdated = items
        .where((e) => !pathsToRemove.contains(e.file.path))
        .toList();

    final activeFileUpdated = filesUpdated
        .where((e) => e.file.path == activeFilePath)
        .firstOrNull
        ?.file
        .path;

    return copyWith(files: filesUpdated, activeFile: () => activeFileUpdated);
  }

  Candidate? itemByPath(String path) =>
      items.where((item) => item.file.path == path).firstOrNull;

  Candidate? get activeCandidate {
    if (activeFilePath == null) {
      return null;
    } else {
      return itemByPath(activeFilePath!);
    }
  }
}
