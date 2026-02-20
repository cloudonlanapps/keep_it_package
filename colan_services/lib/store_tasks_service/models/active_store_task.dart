import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import 'content_origin.dart';
import 'store_task.dart';

enum StoreTaskStep {
  confirmation,
  targetSelection,
  progress,
}

@immutable
class ActiveStoreTask {
  ActiveStoreTask({
    required this.task,
    required this.selectedMedia,
    required this.itemsConfirmed,
    bool? targetConfirmed,
  }) : targetConfirmed = (task.targetCollection != null)
           ? (targetConfirmed ?? true)
           : null;

  final StoreTask task;
  final List<StoreEntity> selectedMedia;
  final bool? itemsConfirmed;
  final bool? targetConfirmed;

  ActiveStoreTask copyWith({
    List<StoreEntity>? selectedMedia,
    bool? Function()? itemsConfirmed,
    bool? Function()? targetConfirmed,
    StoreEntity? Function()? collection,
    List<StoreEntity>? items,
    ContentOrigin? contentOrigin,
  }) {
    final updatedCollection = collection != null
        ? collection()
        : task.targetCollection;

    // Auto-confirm target if collection is present
    // Force null if collection is missing
    final effectiveTargetConfirmed = (updatedCollection != null)
        ? ((targetConfirmed != null)
              ? targetConfirmed()
              : (this.targetConfirmed ?? true))
        : null;

    return ActiveStoreTask(
      task: (items != null) || (contentOrigin != null) || (collection != null)
          ? task.copyWith(
              items: items,
              contentOrigin: contentOrigin,
              collection: collection,
            )
          : task,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      itemsConfirmed: itemsConfirmed != null
          ? itemsConfirmed()
          : this.itemsConfirmed,
      targetConfirmed: effectiveTargetConfirmed,
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
  int get hashCode =>
      task.hashCode ^
      selectedMedia.hashCode ^
      itemsConfirmed.hashCode ^
      targetConfirmed.hashCode;

  List<StoreEntity> get items => task.items;
  ContentOrigin get contentOrigin => task.contentOrigin;
  StoreEntity? get collection => task.targetCollection;

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

  StoreTaskStep get currentStep {
    if (itemsConfirmed == null) {
      return StoreTaskStep.confirmation;
    }
    // Only proceed to progress if target is confirmed AND collection exists
    if ((targetConfirmed ?? false) && collection != null) {
      return StoreTaskStep.progress;
    }
    return StoreTaskStep.targetSelection;
  }
}
