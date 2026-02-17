extension UtilExtensionOnIterableNullable<T> on Iterable<T?> {
  List<T> get nonNullableList {
    return where((e) => e != null).map((e) => e!).toList();
  }

  Set<T> get nonNullableSet {
    return where((e) => e != null).map((e) => e!).toSet();
  }
}
