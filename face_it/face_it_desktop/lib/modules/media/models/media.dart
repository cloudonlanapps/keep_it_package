import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:flutter/material.dart' hide ValueGetter;
import 'package:image_picker/image_picker.dart';

enum MediaStatus {
  added,
  uploading,
  uploaded,

  failed;

  String get message => switch (this) {
    added => 'File not uploaded',
    uploading => 'File is uploading',
    uploaded => 'File is uploaded',
    failed => 'File upload failed',
  };
}

@immutable
class MediaModel {
  const MediaModel({required this.file, this.entity});
  final XFile file;
  final CLEntity? entity;

  MediaModel copyWith({
    XFile? file,
    ValueGetter<CLEntity?>? entity,
    MediaStatus? status,
    ValueGetter<String?>? uploadProgress,
  }) {
    return MediaModel(
      file: file ?? this.file,
      entity: entity != null ? entity.call() : this.entity,
    );
  }

  MediaModel clearEntity() => copyWith(entity: () => null);

  @override
  String toString() {
    return 'SessionCandidate(file: $file, entity: $entity)';
  }

  @override
  bool operator ==(covariant MediaModel other) {
    if (identical(this, other)) return true;

    return other.file == file && other.entity == entity;
  }

  @override
  int get hashCode {
    return file.hashCode ^ entity.hashCode;
  }
}
