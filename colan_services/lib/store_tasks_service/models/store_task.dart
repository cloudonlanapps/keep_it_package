import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:store/store.dart';

import 'content_origin.dart';

@immutable
class StoreTask {
  const StoreTask({
    required this.items,
    required this.contentOrigin,
    this.collection,
  });

  final List<StoreEntity> items;
  final ContentOrigin contentOrigin;
  final StoreEntity? collection;

  StoreTask copyWith({
    List<StoreEntity>? items,
    ContentOrigin? contentOrigin,
    ValueGetter<StoreEntity?>? collection,
  }) {
    return StoreTask(
      items: items ?? this.items,
      contentOrigin: contentOrigin ?? this.contentOrigin,
      collection: collection != null ? collection.call() : this.collection,
    );
  }

  @override
  bool operator ==(covariant StoreTask other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) &&
        other.contentOrigin == contentOrigin &&
        other.collection == collection;
  }

  @override
  int get hashCode =>
      items.hashCode ^ contentOrigin.hashCode ^ collection.hashCode;

  @override
  String toString() =>
      'StoreTask(items: $items, contentOrigin: $contentOrigin, collection: $collection)';
}
