import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'upload_state.dart';
import 'upload_status.dart';

@immutable
class Uploader {
  const Uploader(this.files);
  final Map<String, UploadState> files;

  Uploader copyWith({Map<String, UploadState>? files}) {
    return Uploader(files ?? this.files);
  }

  @override
  String toString() => 'Uploader(files: $files)';

  @override
  bool operator ==(covariant Uploader other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.files, files);
  }

  @override
  int get hashCode => files.hashCode;

  int get uploadCount => files.length;

  int uploadCountByStatus(UploadStatus status) =>
      files.values.where((e) => e.uploadStatus == status).length;

  int get faceRecCount => files.length;
  int faceRecgCountByStatus(ActivityStatus status) =>
      files.values.where((e) => e.faceRecgStatus == status).length;

  String get currentStatus {
    final map = <UploadStatus, int>{};
    for (final status in UploadStatus.values) {
      map[status] = uploadCountByStatus(status);
    }
    final map2 = <ActivityStatus, int>{};
    for (final status in ActivityStatus.values) {
      map2[status] = faceRecgCountByStatus(status);
    }
    return '$map, $map2';
  }
}
