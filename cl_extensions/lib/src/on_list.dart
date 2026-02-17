import 'dart:math';
import 'package:collection/collection.dart';

extension UtilExtensionOnList<T> on List<T> {
  List<T> pickRandomItems(int count) {
    final copyList = List<T>.from(this); // Create a copy of the original list
    if (copyList.length <= count) {
      return copyList; // Return the entire list if it's shorter than 'count'
    }

    copyList.shuffle(Random()); // Shuffle the copy list
    return copyList.take(count).toList();
  }

  bool isSame(List<T> other) {
    // If the lengths are not the same, the lists can't be equal
    if (length != other.length) {
      return false;
    }

    // Sort both lists
    final sortedList1 = List<T>.from(this)..sort();
    final sortedList2 = List<T>.from(other)..sort();

    // Compare the sorted lists
    return ListEquality<T>().equals(sortedList1, sortedList2);
  }

  bool isDifferent(List<T> other) => !isSame(other);

  List<List<T>> convertTo2D(int innerDimension) {
    final pages = <List<T>>[];
    for (var i = 0; i < length; i += innerDimension) {
      final end = (i + innerDimension < length) ? i + innerDimension : length;
      pages.add(sublist(i, end));
    }
    return pages;
  }

  // take?
  List<T> firstNItems(int n) {
    if (length <= n) {
      return this; // Return the list as it is
    } else {
      return sublist(0, n); // Return the first N items
    }
  }

  List<T> removeFirstItem() {
    if (isNotEmpty) {
      return List<T>.from(this)..removeAt(0);
    } else {
      return this;
    }
  }

  Iterable<T> excludeByLabel(
    List<T> another,
    String Function(T obj) labelBuilder,
  ) {
    return where((e) {
      return !another.map(labelBuilder).contains(labelBuilder(e));
    });
  }

  Iterable<T> excludeLabel(String label, String Function(T obj) labelBuilder) {
    return where((e) => labelBuilder(e) != label);
  }

  T? getByLabel(String label, String Function(T obj) labelBuilder) {
    return where((e) => labelBuilder(e) == label).firstOrNull;
  }
}

extension IDGenerator on List<String> {
  String toID() => join(' ');
}
