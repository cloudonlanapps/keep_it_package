import 'package:collection/collection.dart';
import 'package:face_it_desktop/views/server/models/upload_state.dart';
import 'package:face_it_desktop/views/server/models/upload_status.dart';
import 'package:flutter/foundation.dart';

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

  int get count => files.length;

  int countByStatus(UploadStatus status) =>
      files.values.where((e) => e.status == status).length;
}
