import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/foundation.dart';

import '../models/view_modifier.dart';

enum GroupTypes {
  none,
  byOriginalDate;

  String get label =>
      switch (this) { none => 'None', byOriginalDate => 'Original Date' };
}

@immutable
class GroupBy implements ViewModifier {
  const GroupBy({
    this.method = GroupTypes.none,
    this.columns = 3,
  });

  final GroupTypes method;
  final int columns;

  GroupBy copyWith({
    GroupTypes? method,
    int? columns,
  }) {
    return GroupBy(
      method: method ?? this.method,
      columns: columns ?? this.columns,
    );
  }

  @override
  String toString() => 'GroupBy(method: $method, columns: $columns)';

  @override
  bool operator ==(covariant GroupBy other) {
    if (identical(this, other)) return true;

    return other.method == method && other.columns == columns;
  }

  @override
  int get hashCode => method.hashCode ^ columns.hashCode;

  @override
  bool get isActive => false;

  @override
  String get name => 'Group By';

  List<ViewerEntityGroup<ViewerEntity>> getGrouped(
    ViewerEntities entities,
  ) {
    return switch (method) {
      GroupTypes.none => entities.group(columns),
      GroupTypes.byOriginalDate => entities.groupByTime(columns),
    };
  }
}
