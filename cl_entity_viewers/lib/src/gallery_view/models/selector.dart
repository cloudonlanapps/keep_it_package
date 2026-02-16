import 'package:cl_basic_types/viewer_types.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum SelectionStatus { selectedNone, selectedPartial, selectedAll }

@immutable
class CLSelector {
  const CLSelector({
    required this.entities,
    this.items = const {},
  });
  final ViewerEntities entities;
  final Set<ViewerEntity> items;

  CLSelector copyWith({
    ViewerEntities? entities,
    Set<ViewerEntity>? items,
  }) {
    return CLSelector(
      entities: entities ?? this.entities,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(covariant CLSelector other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return collectionEquals(other.entities, entities) &&
        collectionEquals(other.items, items);
  }

  @override
  int get hashCode => entities.hashCode ^ items.hashCode;

  SelectionStatus isSelected(ViewerEntities candidates) {
    if (candidates.entities.every(items.contains)) {
      return SelectionStatus.selectedAll;
    }
    if (candidates.entities.any(items.contains)) {
      return SelectionStatus.selectedPartial;
    }
    return SelectionStatus.selectedNone;
  }

  ViewerEntities selectedItems(ViewerEntities candidates) {
    return ViewerEntities(candidates.entities.where(items.contains).toList());
  }

  CLSelector select(ViewerEntities candidates) {
    return copyWith(items: {...items, ...candidates.entities});
  }

  CLSelector deselect(ViewerEntities candidates) {
    return copyWith(
        items: {...items.where((e) => !candidates.entities.contains(e))});
  }

  CLSelector toggle(ViewerEntities candidates) {
    if (isSelected(candidates) == SelectionStatus.selectedNone) {
      return select(candidates);
    }
    return deselect(candidates);
  }

  CLSelector clear() {
    return CLSelector(entities: entities);
  }

  int get count => items.length;

  @override
  String toString() => 'CLSelector(entities: ${entities.length}, '
      'items: ${items.map((e) => e.id).toList()})';
}
