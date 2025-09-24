import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';

@immutable
class UploadProgress {
  const UploadProgress(this.status, this.progress);
  final TaskStatus status;
  final double progress;

  UploadProgress copyWith({TaskStatus? status, double? progress}) {
    return UploadProgress(status ?? this.status, progress ?? this.progress);
  }

  @override
  String toString() => 'UploadProgress(status: $status, progress: $progress)';

  @override
  bool operator ==(covariant UploadProgress other) {
    if (identical(this, other)) return true;

    return other.status == status && other.progress == progress;
  }

  @override
  int get hashCode => status.hashCode ^ progress.hashCode;
}
