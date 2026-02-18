import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../preference_service/providers/app_preference_provider.dart';
import 'active_store_provider.dart';
import 'refresh_cache.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<ViewerEntities, StoreQuery<CLEntity>>
    with CLLogger {
  @override
  String get logPrefix => 'EntitiesNotifier';

  @override
  FutureOr<ViewerEntities> build(StoreQuery<CLEntity> arg) async {
    // Watch reload trigger
    ref.watch(reloadProvider);

    // Get page size from preferences
    final pageSize = ref.watch(appPreferenceProvider.select((p) => p.pageSize));

    // Force page 1 for initial build
    final dbQuery = arg.copyWith(page: 1, pageSize: pageSize);

    final ViewerEntities result;
    if (dbQuery.store == null) {
      final store = await ref.watch(activeStoreProvider.future);
      result = await store.getAll(dbQuery);
    } else {
      result = await dbQuery.store!.getAll(dbQuery);
    }

    log(
      'Query: ${dbQuery.map} (page ${dbQuery.page}) -> ${result.length} items. '
      'Next: ${result.pagination?.hasNext}',
    );
    return result;
  }

  Future<void> loadNextPage() async {
    final currentEntities = state.value;
    if (currentEntities == null) return;
    if (state.isLoading || state.isRefreshing) return;

    final pagination = currentEntities.pagination;
    if (pagination == null || !pagination.hasNext) return;

    final nextPage = pagination.page + 1;
    final pageSize = pagination.pageSize;

    log('Loading page $nextPage...');

    // We don't want to set state to loading/refreshing because that might clear the UI
    // or show a full screen loader. We want to append silently.
    // However, AsyncNotifier doesn't have a standardized "isLoadingMore" state.
    // For now, we'll just guard against concurrent calls with a boolean flag if needed,
    // but here we can just rely on the future completion.
    // Actually, to show a spinner at the bottom, the UI needs to know we are loading more.
    // But typically infinite scroll just shows the spinner if hasNext is true.

    try {
      final dbQuery = arg.copyWith(page: nextPage, pageSize: pageSize);
      final ViewerEntities result;

      if (dbQuery.store == null) {
        // activeStoreProvider might change, so we should probably read it again
        // or store the one we used efficiently.
        // Using read is safer for callback event handlers to avoid watching.
        final store = await ref.read(activeStoreProvider.future);
        result = await store.getAll(dbQuery);
      } else {
        result = await dbQuery.store!.getAll(dbQuery);
      }

      if (result.isEmpty) {
        log('Page $nextPage returned empty.');
        // Update pagination to stop further attempts if needed,
        // but result.pagination should handle that.
        return;
      }

      // Append
      final newEntities = [...currentEntities.entities, ...result.entities];
      state = AsyncValue.data(
        ViewerEntities(newEntities, pagination: result.pagination),
      );

      log('Appended page $nextPage. Total: ${newEntities.length}');
    } catch (e, st) {
      log('Error loading next page: $e $st');
      // We could set state to error, but that might wipe the list.
      // Better to just log or show a toast via a side-channel.
    }
  }
}

final entitiesProvider =
    AsyncNotifierProviderFamily<
      EntitiesNotifier,
      ViewerEntities,
      StoreQuery<CLEntity>
    >(EntitiesNotifier.new);
