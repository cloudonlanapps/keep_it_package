import 'package:background_downloader/background_downloader.dart';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart' hide ValueGetter;

import 'upload_progress.dart';

enum UploadStatus {
  notQueued,
  ignored,
  pending,
  complete,
  running,
  failed;

  Color get color => switch (this) {
    notQueued => Colors.grey,
    ignored => Colors.orange,
    pending => Colors.yellow,
    complete => Colors.green,
    running => Colors.blue,
    failed => Colors.red,
  };
}

@immutable
class UploadState with CLLogger {
  const UploadState({
    required this.filePath,
    this.uploadProgress,
    this.serverResponse,
    this.identity,
    this.error,
    this.ignored = false,
  });

  final String filePath;

  final UploadProgress? uploadProgress;
  final String? serverResponse;
  final String? identity;
  final String? error;
  final bool ignored;

  @override
  String get logPrefix => 'UploadState';

  UploadState copyWith({
    String? filePath,
    ValueGetter<UploadProgress?>? uploadProgress,
    ValueGetter<String?>? serverResponse,
    ValueGetter<String?>? identity,
    ValueGetter<String?>? error,
    bool? ignored,
  }) {
    return UploadState(
      filePath: filePath ?? this.filePath,
      uploadProgress: uploadProgress != null
          ? uploadProgress.call()
          : this.uploadProgress,
      serverResponse: serverResponse != null
          ? serverResponse.call()
          : this.serverResponse,
      identity: identity != null ? identity.call() : this.identity,
      error: error != null ? error.call() : this.error,
      ignored: ignored ?? this.ignored,
    );
  }

  @override
  String toString() {
    return 'UploadState(filePath: $filePath, uploadProgress: $uploadProgress, serverResponse: $serverResponse, identity: $identity, error: $error, ignored: $ignored)';
  }

  @override
  bool operator ==(covariant UploadState other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath &&
        other.uploadProgress == uploadProgress &&
        other.serverResponse == serverResponse &&
        other.identity == identity &&
        other.error == error &&
        other.ignored == ignored;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        uploadProgress.hashCode ^
        serverResponse.hashCode ^
        identity.hashCode ^
        error.hashCode ^
        ignored.hashCode;
  }

  bool get uploadPending {
    if (ignored) return false;
    if (identity != null) {
      if (uploadProgress?.status == TaskStatus.complete &&
          uploadProgress?.progress == 1.0) {
        return false;
      }
      throw Exception('when having identity, state must have a valid status');
    } else {
      return (uploadProgress == null);
    }
  }

  UploadState get reset => UploadState(filePath: filePath);

  UploadState get setUploadStatusUploading => copyWith(
    serverResponse: () => null,
    uploadProgress: () => const UploadProgress(TaskStatus.enqueued, 0),
    identity: () => null,
    error: () => null,
  );
  UploadState get setUploadStatusIgnore => copyWith(
    serverResponse: () => null,
    uploadProgress: () => null,
    identity: () => null,
    error: () => null,
  );

  UploadState setUploadError(String e) {
    return copyWith(
      serverResponse: () => null,
      uploadProgress: () => const UploadProgress(TaskStatus.failed, 0),
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
      uploadProgress: () => const UploadProgress(TaskStatus.complete, 1),
      identity: () => identity,
      error: () => null,
    );
  }

  UploadState resetUploadError() {
    if (error != null) {
      return copyWith(
        serverResponse: () => null,

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

/// Note this extension is for nullable,
/// we can't merge it with the class
extension StausManipulatorOnUploaderState on UploadState? {
  UploadStatus get uploadStatus {
    return switch (this) {
      null => UploadStatus.notQueued,
      final UploadState _ when this!.ignored => UploadStatus.ignored,
      final UploadState _ when this!.uploadProgress == null =>
        UploadStatus.pending,
      _ => switch (this!.uploadProgress!.status) {
        TaskStatus.complete => UploadStatus.complete,
        TaskStatus.enqueued => UploadStatus.pending,

        TaskStatus.running => UploadStatus.running,
        TaskStatus.waitingToRetry => UploadStatus.running,
        TaskStatus.paused => UploadStatus.running,

        TaskStatus.notFound => UploadStatus.failed,
        TaskStatus.failed => UploadStatus.failed,
        TaskStatus.canceled => UploadStatus.failed,
      },
    };
  }
}
