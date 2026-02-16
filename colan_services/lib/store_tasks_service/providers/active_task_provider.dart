import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/active_store_task.dart';

class ActiveTaskNotifier extends StateNotifier<ActiveStoreTask> {
  // Cannot use super parameter because StateNotifier constructor parameter is private (_state)
  // ignore: use_super_parameters
  ActiveTaskNotifier(ActiveStoreTask state) : super(state);

  set task(ActiveStoreTask task) => state = task;
  ActiveStoreTask get task => state;

  set selectedMedia(List<StoreEntity> items) =>
      state = state.copyWith(selectedMedia: items);
  List<StoreEntity> get selectedMedia => state.selectedMedia;

  ActiveStoreTask? remove(List<StoreEntity> items) {
    final items = [...state.items.where((e) => !state.task.items.contains(e))];
    state = state.copyWith(items: items);
    return state;
  }

  set target(StoreEntity? collection) => state = state.copyWith(
        targetConfirmed: () => true,
        collection: () => collection,
      );
  StoreEntity? get target => state.collection;

  set itemsConfirmed(bool? value) =>
      state = state.copyWith(itemsConfirmed: () => value);
  bool? get itemsConfirmed => state.itemsConfirmed;

  set targetConfirmed(bool? value) =>
      state = state.copyWith(targetConfirmed: () => value);
  bool? get targetConfirmed => state.targetConfirmed;
}

final activeTaskProvider =
    StateNotifierProvider<ActiveTaskNotifier, ActiveStoreTask>((ref) {
  throw Exception('Must override');
});
