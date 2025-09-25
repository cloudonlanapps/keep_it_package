import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;

import 'upload_progress.dart';
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
    this.faces,
    this.uploadProgress,
  });

  final String filePath;
  final UploadStatus uploadStatus;
  final UploadProgress? uploadProgress;
  final ActivityStatus faceRecgStatus;
  final String? serverResponse;
  final String? identity;
  final String? error;
  final List<String>? faces;
  @override
  String get logPrefix => 'UploadState';

  UploadState copyWith({
    String? filePath,
    UploadStatus? uploadStatus,
    ValueGetter<UploadProgress?>? uploadProgress,
    ActivityStatus? faceRecgStatus,
    ValueGetter<String?>? serverResponse,
    ValueGetter<String?>? identity,
    ValueGetter<String?>? error,
    ValueGetter<List<String>?>? faces,
  }) {
    return UploadState(
      filePath: filePath ?? this.filePath,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress != null
          ? uploadProgress.call()
          : this.uploadProgress,
      faceRecgStatus: faceRecgStatus ?? this.faceRecgStatus,
      serverResponse: serverResponse != null
          ? serverResponse.call()
          : this.serverResponse,
      identity: identity != null ? identity.call() : this.identity,
      error: error != null ? error.call() : this.error,
      faces: faces != null ? faces.call() : this.faces,
    );
  }

  @override
  String toString() {
    return 'UploadState(filePath: $filePath, uploadStatus: $uploadStatus, uploadProgress: $uploadProgress, faceRecgStatus: $faceRecgStatus, serverResponse: $serverResponse, identity: $identity, error: $error, faces: $faces)';
  }

  @override
  bool operator ==(covariant UploadState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.filePath == filePath &&
        other.uploadStatus == uploadStatus &&
        other.uploadProgress == uploadProgress &&
        other.faceRecgStatus == faceRecgStatus &&
        other.serverResponse == serverResponse &&
        other.identity == identity &&
        other.error == error &&
        listEquals(other.faces, faces);
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        uploadStatus.hashCode ^
        uploadProgress.hashCode ^
        faceRecgStatus.hashCode ^
        serverResponse.hashCode ^
        identity.hashCode ^
        error.hashCode ^
        faces.hashCode;
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

  bool get allDone => faces != null;

  bool get uploadPending {
    if (identity != null) {
      if (uploadStatus != UploadStatus.success &&
          uploadProgress?.status == TaskStatus.complete &&
          uploadProgress?.progress == 1.0) {
        return false;
      }
      throw Exception('when having identity, state must have a valid status');
    } else {
      return switch (uploadStatus) {
        UploadStatus.pending => true,
        UploadStatus.uploading => false,
        UploadStatus.success => throw Exception('Unexpected state'),
        UploadStatus.error => false,
        UploadStatus.ignore => false,
      };
    }
  }

  UploadState get reset => UploadState(filePath: filePath);

  UploadState get setUploadStatusUploading => copyWith(
    serverResponse: () => null,
    uploadStatus: UploadStatus.uploading,
    identity: () => null,
    error: () => null,
  );
  UploadState get setUploadStatusIgnore => copyWith(
    serverResponse: () => null,
    uploadStatus: UploadStatus.uploading,
    identity: () => null,
    error: () => null,
  );

  UploadState setUploadError(String e) {
    return copyWith(
      serverResponse: () => null,
      uploadStatus: UploadStatus.error,
      identity: () => null,
      error: () => e,
    );
  }

  UploadState setIdentity(
    String identity,
    Map<String, dynamic> serverResponse,
  ) {
    return copyWith(
      serverResponse: () => serverResponse.toString(),
      uploadStatus: UploadStatus.success,
      identity: () => identity,
      error: () => null,
    );
  }

  UploadState resetUploadError() {
    if (uploadStatus == UploadStatus.error) {
      return copyWith(
        serverResponse: () => null,
        uploadStatus: UploadStatus.pending,
        identity: () => null,
        error: () => null,
      );
    }

    return this;
  }

  UploadState setProgress(double progress) {
    return copyWith(
      uploadProgress: () =>
          uploadProgress?.copyWith(progress: progress) ??
          UploadProgress(TaskStatus.running, progress),
    );
  }

  UploadState setStatus(TaskStatus status) {
    return copyWith(
      uploadProgress: () =>
          uploadProgress?.copyWith(status: status) ?? UploadProgress(status, 0),
    );
  }
}
