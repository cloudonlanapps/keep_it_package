import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

@immutable
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationMetadata pagination;

  @override
  String toString() =>
      'PagedResult(items: ${items.length}, pagination: $pagination)';
}
