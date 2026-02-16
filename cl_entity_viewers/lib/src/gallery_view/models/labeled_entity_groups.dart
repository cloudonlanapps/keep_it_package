import 'package:cl_basic_types/viewer_types.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class ViewerEntityGroups {
  const ViewerEntityGroups({
    required this.name,
    required this.galleryGroups,
  });
  final String name;
  final List<ViewerEntityGroup<ViewerEntity>> galleryGroups;

  ViewerEntityGroups copyWith({
    String? name,
    List<ViewerEntityGroup<ViewerEntity>>? galleryGroups,
  }) {
    return ViewerEntityGroups(
      name: name ?? this.name,
      galleryGroups: galleryGroups ?? this.galleryGroups,
    );
  }

  @override
  bool operator ==(covariant ViewerEntityGroups other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name && listEquals(other.galleryGroups, galleryGroups);
  }

  @override
  int get hashCode => name.hashCode ^ galleryGroups.hashCode;

  @override
  String toString() => 'TabData(name: $name, galleryGroups: $galleryGroups)';
}
