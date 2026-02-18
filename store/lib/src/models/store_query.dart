import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'cl_store.dart';

@immutable
class StoreQuery<T> {
  const StoreQuery(
    this.map, {
    this.store,
    this.page = 1,
    this.pageSize = 20,
  });

  final Map<String, dynamic> map;
  final CLStore? store;
  final int page;
  final int pageSize;

  @override
  bool operator ==(covariant StoreQuery<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return mapEquals(other.map, map) &&
        store == other.store &&
        other.page == page &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode =>
      map.entries.fold(store.hashCode, (previousValue, element) {
        return previousValue ^ element.key.hashCode ^ element.value.hashCode;
      }) ^
      page.hashCode ^
      pageSize.hashCode;

  StoreQuery<T> copyWith({
    CLStore? store,
    Map<String, dynamic>? map,
    int? page,
    int? pageSize,
  }) {
    return StoreQuery<T>(
      map ?? this.map,
      store: store ?? this.store,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  String toString() =>
      'StoreQuery(map: $map, store: $store, page: $page, pageSize: $pageSize)';
}

class Shortcuts {
  static StoreQuery<CLEntity> mediaQuery(String storeIdentity, CLEntity media) {
    return StoreQuery<CLEntity>({
      if (media.id != null)
        'id': media.id
      else if (media.isCollection)
        'label': media.label
      else
        'md5': media.md5,
      'isCollection': media.isCollection,
    });
  }
}
