import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class PaginationMetadata {
  const PaginationMetadata({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMetadata.fromMap(Map<String, dynamic> map) {
    return PaginationMetadata(
      page: map['page'] as int,
      pageSize: map['page_size'] as int,
      totalItems: map['total_items'] as int,
      totalPages: map['total_pages'] as int,
      hasNext: map['has_next'] as bool,
      hasPrev: map['has_prev'] as bool,
    );
  }

  factory PaginationMetadata.fromJson(String source) =>
      PaginationMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMetadata copyWith({
    int? page,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
  }) {
    return PaginationMetadata(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PaginationMetadata(page: $page, pageSize: $pageSize, '
        'totalItems: $totalItems, totalPages: $totalPages, '
        'hasNext: $hasNext, hasPrev: $hasPrev)';
  }

  @override
  bool operator ==(covariant PaginationMetadata other) {
    if (identical(this, other)) return true;

    return other.page == page &&
        other.pageSize == pageSize &&
        other.totalItems == totalItems &&
        other.totalPages == totalPages &&
        other.hasNext == hasNext &&
        other.hasPrev == hasPrev;
  }

  @override
  int get hashCode {
    return page.hashCode ^
        pageSize.hashCode ^
        totalItems.hashCode ^
        totalPages.hashCode ^
        hasNext.hashCode ^
        hasPrev.hashCode;
  }
}
