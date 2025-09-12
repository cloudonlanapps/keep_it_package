import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:face_it_desktop/models/face.dart';
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
class SessionCandidate {
  const SessionCandidate({
    required this.file,
    this.entity,
    this.status = MediaStatus.added,
    this.uploadProgress,
    this.faces,
  });
  final XFile file;

  final CLEntity? entity;
  final MediaStatus status;
  final String? uploadProgress;
  final List<DetectedFace>? faces;

  SessionCandidate copyWith({
    XFile? file,
    ValueGetter<CLEntity?>? entity,
    MediaStatus? status,
    ValueGetter<String?>? uploadProgress,
    ValueGetter<List<DetectedFace>?>? faces,
  }) {
    return SessionCandidate(
      file: file ?? this.file,
      entity: entity != null ? entity.call() : this.entity,
      status: status ?? this.status,
      uploadProgress: uploadProgress != null
          ? uploadProgress.call()
          : this.uploadProgress,
      faces: faces != null ? faces.call() : this.faces,
    );
  }

  SessionCandidate entityFromMap(Map<String, dynamic> map) {
    final entity = CLEntity(
      id: null,
      isCollection: false,
      addedDate: DateTime.fromMillisecondsSinceEpoch(
        (map['addedDate'] ?? 0) as int,
      ),
      updatedDate: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedDate'] ?? 0) as int,
      ),
      isDeleted: (map['isDeleted'] ?? 0) != 0,
      label: map['file_identifier'] != null
          ? map['file_identifier'] as String
          : null,
      description: map['description'] != null
          ? map['description'] as String
          : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      md5: map['md5'] != null ? map['md5'] as String : null,
      fileSize: map['fileSize'] != null ? map['fileSize'] as int : null,
      mimeType: map['mimeType'] != null ? map['mimeType'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      extension: map['extension'] != null ? map['extension'] as String : null,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createDate'] ?? 0) as int)
          : null,
      height: map['height'] != null ? map['height'] as int : null,
      width: map['width'] != null ? map['width'] as int : null,
      duration: map['duration'] != null ? map['duration'] as double : null,
      isHidden: (map['isHidden'] ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
    );
    return copyWith(entity: () => entity);
  }

  SessionCandidate clearEntity() => copyWith(entity: () => null);

  @override
  String toString() {
    return 'SessionCandidate(file: $file, entity: $entity, status: $status, uploadProgress: $uploadProgress, faces: $faces)';
  }

  @override
  bool operator ==(covariant SessionCandidate other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.file == file &&
        other.entity == entity &&
        other.status == status &&
        other.uploadProgress == uploadProgress &&
        listEquals(other.faces, faces);
  }

  @override
  int get hashCode {
    return file.hashCode ^
        entity.hashCode ^
        status.hashCode ^
        uploadProgress.hashCode ^
        faces.hashCode;
  }

  String get statusString => status.message;

  bool get isUploaded => entity?.label != null;
}
