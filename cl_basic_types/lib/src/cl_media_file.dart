// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:io';

import 'package:cl_basic_types/src/extensions/on_date_time.dart';
import 'package:meta/meta.dart';

import 'cl_media_content.dart';
import 'cl_media_type.dart';
import 'value_getter.dart';

@immutable
class CLMediaFile extends CLMediaContent {
  final String path;
  final String md5;
  final int fileSize;
  final String mimeType;
  final CLMediaType type;
  final String fileSuffix;
  final DateTime? createDate;
  final int? height;
  final int? width;
  final double? duration;
  const CLMediaFile({
    required this.path,
    required this.md5,
    required this.fileSize,
    required this.mimeType,
    required this.type,
    required this.fileSuffix,
    this.createDate,
    this.height,
    this.width,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'md5': md5,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type.name,
      'fileSuffix': fileSuffix,
      'createDate': createDate?.utcTimeStamp,
      'height': height,
      'width': width,
      'duration': duration,
    };
  }

  factory CLMediaFile.fromMap(Map<String, dynamic> map) {
    return CLMediaFile(
      path: (map['path'] ?? '') as String,
      md5: (map['md5'] ?? '') as String,
      fileSize: (map['fileSize'] ?? 0) as int,
      mimeType: (map['mimeType'] ?? '') as String,
      type: CLMediaType.values.firstWhere(
        (e) => (map['mimeType'] as String).startsWith(e.name),
        orElse: () => throw ArgumentError('Invalid MediaType: ${map['name']}'),
      ),
      fileSuffix: (map['fileSuffix'] ?? '') as String,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createDate'] ?? 0) as int)
          : null,
      height: map['height'] != null ? map['height'] as int : null,
      width: map['width'] != null ? map['width'] as int : null,
      duration: map['duration'] != null ? map['duration'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLMediaFile.fromJson(String source) =>
      CLMediaFile.fromMap(json.decode(source) as Map<String, dynamic>);

  CLMediaFile copyWith({
    String? path,
    String? md5,
    int? fileSize,
    String? mimeType,
    CLMediaType? type,
    String? fileSuffix,
    ValueGetter<DateTime?>? createDate,
    ValueGetter<int?>? height,
    ValueGetter<int?>? width,
    ValueGetter<double?>? duration,
  }) {
    return CLMediaFile(
      path: path ?? this.path,
      md5: md5 ?? this.md5,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      fileSuffix: fileSuffix ?? this.fileSuffix,
      createDate: createDate != null ? createDate.call() : this.createDate,
      height: height != null ? height.call() : this.height,
      width: width != null ? width.call() : this.width,
      duration: duration != null ? duration.call() : this.duration,
    );
  }

  @override
  String toString() {
    return 'CLMediaFile(path: $path, md5: $md5, fileSize: $fileSize, mimeType: $mimeType, type: $type, fileSuffix: $fileSuffix, createDate: $createDate, height: $height, width: $width, duration: $duration)';
  }

  @override
  bool operator ==(covariant CLMediaFile other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.md5 == md5 &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.type == type &&
        other.fileSuffix == fileSuffix &&
        other.createDate == createDate &&
        other.height == height &&
        other.width == width &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        md5.hashCode ^
        fileSize.hashCode ^
        mimeType.hashCode ^
        type.hashCode ^
        fileSuffix.hashCode ^
        createDate.hashCode ^
        height.hashCode ^
        width.hashCode ^
        duration.hashCode;
  }

  void deleteFile() {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  @override
  String get identity => path;
}
