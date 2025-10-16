import 'package:collection/collection.dart';

import 'base_filter.dart';

class EnumFilter<T, E> extends BaseFilter<T, E> {
  EnumFilter({
    required super.name,
    required this.labels,
    required super.fieldSelector,
    required super.enabled,
    required super.isByPassed,
  }) : selectedValues = [],
       referenceIndex = {
         for (final (index, value) in labels.keys.indexed) value: index,
       },
       super(filterType: FilterType.enumFilter);
  const EnumFilter._({
    required super.name,
    required this.labels,
    required super.fieldSelector,
    required this.selectedValues,
    required this.referenceIndex,
    required super.enabled,
    required super.isByPassed,
  }) : super(filterType: FilterType.enumFilter);
  final List<E> selectedValues;
  final Map<E, String> labels;
  final Map<E, int> referenceIndex;

  @override
  List<T> apply(List<T> items) {
    if (selectedValues.isEmpty) return items;
    if (!enabled) return items;
    if (selectedValues.length == labels.entries.length) return items;

    return items
        .where(
          (item) =>
              isByPassed(item) || selectedValues.contains(fieldSelector(item)),
        )
        .toList();
  }

  @override
  EnumFilter<T, E> update(String key, dynamic value) {
    return switch (key) {
      'enable' => _enable(value as bool),
      'select' => _select(value as E),
      'deselect' => _deselect(value as E),
      'clear' => _clear(),
      _ => _toggle(value as E),
    };
  }

  EnumFilter<T, E> _enable(bool value) {
    return EnumFilter<T, E>._(
      name: name,
      fieldSelector: fieldSelector,
      isByPassed: isByPassed,
      labels: labels,
      referenceIndex: referenceIndex,
      selectedValues: selectedValues,
      enabled: value,
    );
  }

  @override
  bool operator ==(covariant EnumFilter<T, E> other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return collectionEquals(other.selectedValues, selectedValues) &&
        collectionEquals(other.labels, labels) &&
        collectionEquals(other.referenceIndex, referenceIndex) &&
        super == other;
  }

  @override
  int get hashCode =>
      selectedValues.hashCode ^
      labels.hashCode ^
      referenceIndex.hashCode ^
      super.hashCode;

  EnumFilter<T, E> _select(E value) {
    if (!selectedValues.contains(value)) {
      final selectedValues = List<E>.from(this.selectedValues)
        ..add(value)
        ..sort((a, b) {
          return referenceIndex[a]!.compareTo(referenceIndex[b]!);
        });
      return EnumFilter<T, E>._(
        name: name,
        fieldSelector: fieldSelector,
        isByPassed: isByPassed,
        labels: labels,
        referenceIndex: referenceIndex,
        selectedValues: selectedValues,
        enabled: true,
      );
    }
    return this;
  }

  EnumFilter<T, E> _deselect(E value) {
    if (selectedValues.contains(value)) {
      final selectedValues = this.selectedValues
          .where((e) => e != value)
          .toList();
      return EnumFilter<T, E>._(
        name: name,
        fieldSelector: fieldSelector,
        isByPassed: isByPassed,
        labels: labels,
        referenceIndex: referenceIndex,
        selectedValues: selectedValues,
        enabled: true,
      );
    }
    return this;
  }

  EnumFilter<T, E> _clear() {
    return EnumFilter<T, E>._(
      name: name,
      fieldSelector: fieldSelector,
      isByPassed: isByPassed,
      labels: labels,
      referenceIndex: referenceIndex,
      selectedValues: const [],
      enabled: true,
    );
  }

  EnumFilter<T, E> _toggle(E value) {
    if (selectedValues.contains(value)) {
      return _deselect(value);
    } else {
      return _select(value);
    }
  }

  @override
  String toString() => 'EnumFilter(selectedValues: $selectedValues)';

  @override
  bool get isActive => enabled && selectedValues.isNotEmpty;
}
