import 'package:cl_extensions/cl_extensions.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'viewer_entity_mixin.dart';

@immutable
class ViewerEntities {
  const ViewerEntities(this.entities);
  final List<ViewerEntity> entities;

  ViewerEntities copyWith({List<ViewerEntity>? entities}) {
    return ViewerEntities(entities ?? this.entities);
  }

  @override
  String toString() => 'ViewerEntities(entities: $entities)';

  @override
  bool operator ==(covariant ViewerEntities other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entities, entities);
  }

  @override
  int get hashCode => entities.hashCode;

  int get length => entities.length;

  bool get isEmpty => entities.isEmpty;
  bool get isNotEmpty => entities.isNotEmpty;

  Future<ViewerEntities> mergeMismatch(int? parentId) async {
    final items = <ViewerEntity>[];
    for (final e in entities.cast<ViewerEntity>()) {
      final item = await e.updateWith(
        isDeleted: () => false,
        parentId: () => parentId,
      );
      if (item != null) {
        items.add(item);
      }
    }
    return ViewerEntities(items.toList());
  }

  ViewerEntities? removeMismatch(int? parentId) {
    final items = entities.cast<ViewerEntity>().where(
      (e) => e.parentId == parentId || (e.isHidden),
    );
    if (items.isEmpty) return null;

    return ViewerEntities(items.toList());
  }

  ViewerEntities? remove(ViewerEntity itemToRemove) {
    final items = entities.where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return ViewerEntities(items.toList());
  }

  Iterable<ViewerEntity> get _stored => entities.where((e) => e.id != null);
  Iterable<ViewerEntity> _targetMismatch(int? parentId) =>
      _stored.where((e) => e.parentId != parentId && !e.isHidden);

  ViewerEntities targetMismatch(int? parentId) =>
      ViewerEntities(_targetMismatch(parentId).toList());
  ViewerEntities get stored => ViewerEntities(_stored.toList());

  Map<String, List<ViewerEntity>> filterByDate() {
    final filterredMedia = <String, List<ViewerEntity>>{};
    final noDate = <ViewerEntity>[];
    for (final entry in entities) {
      final String formattedDate;

      if (entry.createDate != null) {
        formattedDate = entry.createDate!.toDisplayFormat(dataOnly: true);
      } else {
        formattedDate =
            '${entry.updatedDate.toDisplayFormat(dataOnly: true)} '
            '(upload date)';
      }

      if (!filterredMedia.containsKey(formattedDate)) {
        filterredMedia[formattedDate] = [];
      }
      filterredMedia[formattedDate]!.add(entry);
    }
    if (noDate.isNotEmpty) {
      filterredMedia['No Date'] = noDate;
    }

    return filterredMedia;
  }

  List<ViewerEntityGroup<ViewerEntity>> groupByTime(int columns) {
    final galleryGroups = <ViewerEntityGroup<ViewerEntity>>[];

    for (final entry in filterByDate().entries) {
      if (entry.value.length > columns) {
        final groups = entry.value.convertTo2D(columns);

        for (final (index, group) in groups.indexed) {
          galleryGroups.add(
            ViewerEntityGroup(
              group,
              label: (index == 0) ? entry.key : null,
              groupIdentifier: entry.key,
              chunkIdentifier: '${entry.key} $index',
            ),
          );
        }
      } else {
        galleryGroups.add(
          ViewerEntityGroup(
            entry.value,
            label: entry.key,
            groupIdentifier: entry.key,
            chunkIdentifier: entry.key,
          ),
        );
      }
    }
    return galleryGroups;
  }

  List<ViewerEntityGroup<ViewerEntity>> group(int columns) {
    final galleryGroups = <ViewerEntityGroup<ViewerEntity>>[];

    for (final rows in entities.convertTo2D(columns)) {
      galleryGroups.add(
        ViewerEntityGroup(
          rows,
          label: null,
          groupIdentifier: 'StoreEntity',
          chunkIdentifier: 'StoreEntity',
        ),
      );
    }
    return galleryGroups;
  }
}
