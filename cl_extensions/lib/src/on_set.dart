import 'package:collection/collection.dart';

extension UtilExtensionOnSet<T> on Set<T> {
  bool isSame(Set<T> other) {
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

  bool isDifferent(Set<T> other) => !isSame(other);
}
