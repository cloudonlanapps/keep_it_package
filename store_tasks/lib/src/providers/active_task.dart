import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/content_origin.dart';
import '../models/store_task.dart';

@immutable
class ActiveStoreTask {
  const ActiveStoreTask(
      {required this.task,
      required this.selectedMedia,
      required this.itemsConfirmed,
      required this.targetConfirmed});

  final StoreTask task;
  final List<StoreEntity> selectedMedia;
  final bool? itemsConfirmed;
  final bool? targetConfirmed;

  ActiveStoreTask copyWith(
      {List<StoreEntity>? selectedMedia,
      bool? Function()? itemsConfirmed,
      bool? Function()? targetConfirmed,
      StoreEntity? Function()? collection,
      List<StoreEntity>? items,
      ContentOrigin? contentOrigin}) {
    return ActiveStoreTask(
      task: (items != null) || (contentOrigin != null) || (collection != null)
          ? task.copyWith(
              items: items,
              contentOrigin: contentOrigin,
              collection: collection)
          : task,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      itemsConfirmed:
          itemsConfirmed != null ? itemsConfirmed() : this.itemsConfirmed,
      targetConfirmed:
          targetConfirmed != null ? targetConfirmed() : this.targetConfirmed,
    );
  }

  @override
  String toString() {
    return 'ActiveStoreTask(task: $task, selectedMedia: $selectedMedia, itemsConfirmed: $itemsConfirmed, targetConfirmed: $targetConfirmed)';
  }

  @override
  bool operator ==(covariant ActiveStoreTask other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.task == task &&
        listEquals(other.selectedMedia, selectedMedia) &&
        other.itemsConfirmed == itemsConfirmed &&
        other.targetConfirmed == targetConfirmed;
  }

  @override
  int get hashCode {
    return task.hashCode ^
        selectedMedia.hashCode ^
        itemsConfirmed.hashCode ^
        targetConfirmed.hashCode;
  }

  List<StoreEntity> get items => task.items;
  ContentOrigin get contentOrigin => task.contentOrigin;
  StoreEntity? get collection => task.collection;

  bool get selectable => (itemsConfirmed == null) && items.length > 1;

  String keepActionLabel({required bool selectionMode}) => [
        contentOrigin.keepActionLabel,
        if (selectionMode) 'Selected' else items.length > 1 ? 'All' : '',
      ].join(' ');
  String deleteActionLabel({required bool selectionMode}) => [
        contentOrigin.deleteActionLabel,
        if (selectionMode) 'Selected' else items.length > 1 ? 'All' : '',
      ].join(' ');

  List<StoreEntity> currEntities({required bool selectionMode}) =>
      (selectionMode ? selectedMedia : items);
}

class ActiveTaskNotifier extends StateNotifier<ActiveStoreTask> {
  ActiveTaskNotifier(super.task);

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

  set target(StoreEntity? collection) => state =
      state.copyWith(targetConfirmed: () => true, collection: () => collection);
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
