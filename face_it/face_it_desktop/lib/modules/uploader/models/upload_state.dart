import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;

import 'upload_status.dart';

@immutable
class UploadState {
  const UploadState({
    required this.filePath,
    this.status = UploadStatus.pending,
    this.serverResponse,
    this.error,
    this.entity,
  });

  final String filePath;
  final UploadStatus status;
  final String? serverResponse;
  final CLEntity? entity;
  final String? error;

  UploadState copyWith({
    UploadStatus? status,
    ValueGetter<String?>? serverResponse,
    ValueGetter<CLEntity?>? entity,
    ValueGetter<String?>? error,
  }) {
    return UploadState(
      filePath: filePath,
      status: status ?? this.status,
      serverResponse: serverResponse != null
          ? serverResponse.call()
          : this.serverResponse,
      entity: entity != null ? entity.call() : this.entity,
      error: error != null ? error.call() : this.error,
    );
  }

  @override
  String toString() {
    return 'UploadState( filePath: $filePath, status: $status, serverResponse: $serverResponse, error: $error)';
  }

  @override
  bool operator ==(covariant UploadState other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath &&
        other.status == status &&
        other.serverResponse == serverResponse &&
        other.error == error;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        status.hashCode ^
        serverResponse.hashCode ^
        error.hashCode;
  }

  static CLEntity entityFromMap(Map<String, dynamic> map) {
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
    return entity;
  }

  String get statusString => switch (status) {
    UploadStatus.pending => 'Waiting to upload',
    UploadStatus.uploading => 'uploading: $serverResponse',
    UploadStatus.success => 'Upload Successful',
    UploadStatus.error => 'Upload Failed',
  };
}
