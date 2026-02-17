import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'active_store_provider.dart';
import 'refresh_cache.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<ViewerEntities, StoreQuery<CLEntity>>
    with CLLogger {
  @override
  String get logPrefix => 'EntitiesNotifier';
  @override
  FutureOr<ViewerEntities> build(StoreQuery<CLEntity> arg) async {
    final dbQuery = arg;

    ref.watch(reloadProvider);
    if (dbQuery.store == null) {
      final store = await ref.watch(activeStoreProvider.future);
      return store.getAll(dbQuery);
    } else {
      return dbQuery.store!.getAll(dbQuery);
    }
  }
}

final entitiesProvider = AsyncNotifierProviderFamily<EntitiesNotifier,
    ViewerEntities, StoreQuery<CLEntity>>(EntitiesNotifier.new);
