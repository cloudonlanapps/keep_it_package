import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'cl_store.dart';

@immutable
class StoreQuery<T> {
  const StoreQuery(this.map, {this.store});

  final Map<String, dynamic> map;
  final CLStore? store;

  @override
  bool operator ==(covariant StoreQuery<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return mapEquals(other.map, map) && store == other.store;
  }

  @override
  int get hashCode =>
      map.entries.fold(store.hashCode, (previousValue, element) {
        return previousValue ^ element.key.hashCode ^ element.value.hashCode;
      });

  StoreQuery<T> copyWith({
    CLStore? store,
    Map<String, dynamic>? map,
  }) {
    return StoreQuery<T>(map ?? this.map, store: store ?? this.store);
  }

  @override
  String toString() => 'StoreQuery(map: $map, store: $store)';
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
