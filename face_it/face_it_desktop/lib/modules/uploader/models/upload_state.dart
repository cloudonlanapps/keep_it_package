import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;

import 'upload_status.dart';

enum ActivityStatus {
  premature,
  pending,
  processingNow,
  success,
  error,
  ignore,
}

@immutable
class UploadState with CLLogger {
  const UploadState({
    required this.filePath,
    this.uploadStatus = UploadStatus.pending,
    this.faceRecgStatus = ActivityStatus.premature,
    this.serverResponse,
    this.error,
    this.identity,
  });

  final String filePath;
  final UploadStatus uploadStatus;
  final ActivityStatus faceRecgStatus;
  final String? serverResponse;
  final String? identity;
  final String? error;
  @override
  String get logPrefix => 'UploadState';

  UploadState copyWith({
    String? filePath,
    UploadStatus? uploadStatus,
    ActivityStatus? faceRecgStatus,
    ValueGetter<String?>? serverResponse,
    ValueGetter<String?>? identity,
    ValueGetter<String?>? error,
  }) {
    return UploadState(
      filePath: filePath ?? this.filePath,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      faceRecgStatus: faceRecgStatus ?? this.faceRecgStatus,
      serverResponse: serverResponse != null
          ? serverResponse.call()
          : this.serverResponse,
      identity: identity != null ? identity.call() : this.identity,
      error: error != null ? error.call() : this.error,
    );
  }

  @override
  String toString() {
    return 'UploadState(filePath: $filePath, uploadStatus: $uploadStatus, faceRecgStatus: $faceRecgStatus, serverResponse: $serverResponse, identity: $identity, error: $error)';
  }

  @override
  bool operator ==(covariant UploadState other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath &&
        other.uploadStatus == uploadStatus &&
        other.faceRecgStatus == faceRecgStatus &&
        other.serverResponse == serverResponse &&
        other.identity == identity &&
        other.error == error;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        uploadStatus.hashCode ^
        faceRecgStatus.hashCode ^
        serverResponse.hashCode ^
        identity.hashCode ^
        error.hashCode;
  }

  String get statusString => switch (uploadStatus) {
    UploadStatus.pending => 'Waiting to upload',
    UploadStatus.uploading => 'uploading: $serverResponse',
    UploadStatus.success => 'Upload Successful',
    UploadStatus.error => 'Upload Failed',
    UploadStatus.ignore => 'Manual upload only',
  };
  bool get faceScanPossible {
    return uploadStatus == UploadStatus.success &&
        identity != null &&
        switch (faceRecgStatus) {
          ActivityStatus.premature ||
          ActivityStatus.error ||
          ActivityStatus.success => true,

          ActivityStatus.pending ||
          ActivityStatus.processingNow ||
          ActivityStatus.ignore => false,
        };
  }

  bool get faceScanNeeded {
    return uploadStatus == UploadStatus.success &&
        switch (faceRecgStatus) {
          ActivityStatus.premature => true,

          ActivityStatus.pending ||
          ActivityStatus.processingNow ||
          ActivityStatus.ignore ||
          ActivityStatus.error ||
          ActivityStatus.success => false,
        };
  }

  bool get faceScanInProgress {
    return uploadStatus == UploadStatus.success &&
        switch (faceRecgStatus) {
          ActivityStatus.pending || ActivityStatus.processingNow => true,

          ActivityStatus.premature ||
          ActivityStatus.ignore ||
          ActivityStatus.error ||
          ActivityStatus.success => false,
        };
  }

  bool get uploadRequired {
    switch (uploadStatus) {
      case UploadStatus.uploading:
      case UploadStatus.success:
      case UploadStatus.ignore:
        return false;
      case UploadStatus.pending:
      case UploadStatus.error: // Need to retry

        return true;
    }
  }
}
