import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

@immutable
class ServerTimeStamps {
  const ServerTimeStamps({this.collection, this.media});

  factory ServerTimeStamps.fromMap(Map<String, dynamic> map) {
    return ServerTimeStamps(
      collection: map['collection'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['collection'] as int)
          : null,
      media: map['media'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['media'] as int)
          : null,
    );
  }

  factory ServerTimeStamps.fromJson(String source) =>
      ServerTimeStamps.fromMap(json.decode(source) as Map<String, dynamic>);
  final DateTime? collection;
  final DateTime? media;

  @override
  bool operator ==(covariant ServerTimeStamps other) {
    if (identical(this, other)) return true;

    return other.collection == collection && other.media == media;
  }

  @override
  int get hashCode => collection.hashCode ^ media.hashCode;

  @override
  String toString() =>
      'ServerTimeStamps(collection: $collection, media: $media)';

  ServerTimeStamps copyWith({
    ValueGetter<DateTime?>? collection,
    ValueGetter<DateTime?>? media,
  }) {
    return ServerTimeStamps(
      collection: collection != null ? collection.call() : this.collection,
      media: media != null ? media.call() : this.media,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'collection': collection?.utcTimeStamp,
      'media': media?.utcTimeStamp,
    };
  }

  String toJson() => json.encode(toMap());
}
