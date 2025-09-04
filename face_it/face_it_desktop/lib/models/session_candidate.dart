import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart' hide ValueGetter;

enum MediaStatus { added, uploading, uploaded }

@immutable
class SessionCandidate {
  const SessionCandidate({
    required this.path,
    required this.label,
    this.entity,
    this.status = MediaStatus.added,
  });
  final String path;
  final String label;

  final CLEntity? entity;
  final MediaStatus status;

  SessionCandidate copyWith({
    String? path,
    String? label,
    ValueGetter<CLEntity?>? entity,
    MediaStatus? status,
  }) {
    return SessionCandidate(
      path: path ?? this.path,
      label: label ?? this.label,
      entity: entity != null ? entity.call() : this.entity,
      status: status ?? this.status,
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
    return 'MediaDescriptor(path: $path, label: $label, entity: $entity, status: $status)';
  }

  @override
  bool operator ==(covariant SessionCandidate other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.label == label &&
        other.entity == entity &&
        other.status == status;
  }

  @override
  int get hashCode {
    return path.hashCode ^ label.hashCode ^ entity.hashCode ^ status.hashCode;
  }
}


/* 
{
  "createDate": null,
  "duration": null,
  "fileSize": 42214,
  "file_identifier": "3789db620aa8136331c1b321e344112d.jpg",
  "height": 500,
  "md5": "3789db620aa8136331c1b321e344112d",
  "mimeType": "image/jpeg",
  "status": "duplicate",
  "width": 483
} */