import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
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
    final ViewerEntities result;
    if (dbQuery.store == null) {
      final store = await ref.watch(activeStoreProvider.future);
      result = await store.getAll(dbQuery);
    } else {
      result = await dbQuery.store!.getAll(dbQuery);
    }
    log('Query: ${dbQuery.map} -> ${result.length} items');
    return result;
  }
}

final entitiesProvider =
    AsyncNotifierProviderFamily<
      EntitiesNotifier,
      ViewerEntities,
      StoreQuery<CLEntity>
    >(EntitiesNotifier.new);
