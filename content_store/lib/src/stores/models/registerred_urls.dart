import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class RegisteredURLs {
  factory RegisteredURLs(
      {required List<CLUrl> availableStores, required int activeStoreIndex}) {
    final stores = availableStores;
    // Not a good idea when network involved. need more checks
    if (stores.isEmpty) {
      throw Exception('atleast one store must be available');
    }
    return RegisteredURLs._(
        availableStores: stores,
        activeStoreIndex:
            activeStoreIndex > stores.length ? activeStoreIndex : 0);
  }
  const RegisteredURLs._({
    required this.availableStores,
    required this.activeStoreIndex,
  });
  final List<CLUrl> availableStores;
  final int activeStoreIndex;

  RegisteredURLs copyWith({
    List<CLUrl>? availableStores,
    int? activeStoreIndex,
  }) {
    return RegisteredURLs._(
      availableStores: availableStores ?? this.availableStores,
      activeStoreIndex: activeStoreIndex ?? this.activeStoreIndex,
    );
  }

  @override
  bool operator ==(covariant RegisteredURLs other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.availableStores, availableStores) &&
        other.activeStoreIndex == activeStoreIndex;
  }

  @override
  int get hashCode => availableStores.hashCode ^ activeStoreIndex.hashCode;

  @override
  String toString() =>
      'AvailableStores(availableStores: $availableStores, activeStoreIndex: $activeStoreIndex)';

  RegisteredURLs setActiveStore(CLUrl storeURL) {
    if (!availableStores.contains(storeURL)) {
      throw Exception('Store is not registered');
    }
    return copyWith(
        activeStoreIndex: availableStores.indexWhere((e) => e == storeURL));
  }

  RegisteredURLs addStore(CLUrl storeURL) {
    if (availableStores.contains(storeURL)) {
      throw Exception('Store already exists');
    }
    final stores = List<CLUrl>.from(availableStores)
      ..add(storeURL)
      ..sort();

    final index = stores.indexWhere((e) => e == storeURL);
    return copyWith(availableStores: stores, activeStoreIndex: index);
  }

  RegisteredURLs removeStore(CLUrl storeURL) {
    if (!availableStores.contains(storeURL)) {
      throw Exception('Store is not registered');
    }
    if (isDefaultStore(storeURL)) {
      throw Exception("Default store can't be removed");
    }
    final index = (isActiveStore(storeURL)) ? 0 : activeStoreIndex;

    final stores = List<CLUrl>.from(availableStores)..remove(storeURL);
    return copyWith(availableStores: stores, activeStoreIndex: index);
  }

  bool isDefaultStore(CLUrl storeURL) {
    return storeURL == defaultStoreURL;
  }

  bool isActiveStore(CLUrl storeURL) {
    return storeURL == availableStores[activeStoreIndex];
  }

  CLUrl get activeStoreURL => availableStores[activeStoreIndex];
  CLUrl get defaultStoreURL => availableStores[0];

  List<CLUrl> get onlineStores => availableStores
      .where((e) => ['http', 'https'].contains(e.scheme))
      .toList();
}
