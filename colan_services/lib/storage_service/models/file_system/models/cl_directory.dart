import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

@immutable
class CLDirectory {
  const CLDirectory({
    required this.label,
    required this.name,
    required this.baseDir,
    required this.isStore,
    String? description,
  }) : description0 = description;
  final String label;
  final String name;
  final Directory baseDir;
  final String? description0;
  final bool isStore;

  Directory get path => Directory(p.join(baseDir.path, name));
  String get pathString => path.path;
  String get description => description0 ?? label;

  String get relativePath => name;

  CLDirectory copyWith({
    String? label,
    String? name,
    Directory? baseDir,
    String? description0,
    bool? isStore,
  }) {
    return CLDirectory(
      label: label ?? this.label,
      name: name ?? this.name,
      baseDir: baseDir ?? this.baseDir,
      description: description0 ?? this.description0,
      isStore: isStore ?? this.isStore,
    );
  }

  @override
  String toString() {
    return 'CLDirectory(label: $label, name: $name, baseDir: $baseDir, description0: $description0, isStore: $isStore)';
  }

  @override
  bool operator ==(covariant CLDirectory other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.name == name &&
        other.baseDir == baseDir &&
        other.description0 == description0 &&
        other.isStore == isStore;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        name.hashCode ^
        baseDir.hashCode ^
        description0.hashCode ^
        isStore.hashCode;
  }

  void create() {
    if (!path.existsSync()) {
      path.createSync(recursive: true);
    }
  }
}
