import 'package:cl_extensions/cl_extensions.dart' show ValueGetter;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:store/store.dart';

import 'content_origin.dart';

@immutable
class StoreTask {
  const StoreTask({
    required this.items,
    required this.contentOrigin,
    this.targetCollection,
  });

  final List<StoreEntity> items;
  final ContentOrigin contentOrigin;
  final StoreEntity? targetCollection;

  StoreTask copyWith({
    List<StoreEntity>? items,
    ContentOrigin? contentOrigin,
    ValueGetter<StoreEntity?>? collection,
  }) {
    return StoreTask(
      items: items ?? this.items,
      contentOrigin: contentOrigin ?? this.contentOrigin,
      targetCollection: collection != null
          ? collection.call()
          : this.targetCollection,
    );
  }

  @override
  bool operator ==(covariant StoreTask other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) &&
        other.contentOrigin == contentOrigin &&
        other.targetCollection == targetCollection;
  }

  @override
  int get hashCode =>
      items.hashCode ^ contentOrigin.hashCode ^ targetCollection.hashCode;

  @override
  String toString() =>
      'StoreTask(items: $items, contentOrigin: $contentOrigin, collection: $targetCollection)';
}
