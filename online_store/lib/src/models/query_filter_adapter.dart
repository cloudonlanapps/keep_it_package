import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:store/store.dart';

/// Result of adapting a StoreQuery to StoreManager parameters.
class AdaptedQueryParams {
  const AdaptedQueryParams({
    this.idFilter,
    this.labelFilter,
    this.md5,
    this.mimeType,
    this.type,
    this.width,
    this.height,
    this.fileSizeMin,
    this.fileSizeMax,
    this.dateFrom,
    this.dateTo,
    this.excludeDeleted,
    this.parentId,
    this.isCollection,
    this.pinFilter,
    this.page,
    this.pageSize,
    this.otherFilters = const {},
  });

  // Special filters
  final int? idFilter; // Use readEntity() instead of listEntities()
  final String? labelFilter; // Use lookupEntity() for exact match

  // Server-side filters (passed to listEntities)
  final String? md5;
  final String? mimeType;
  final String? type;
  final int? width;
  final int? height;
  final int? fileSizeMin;
  final int? fileSizeMax;
  final int? dateFrom;
  final int? dateTo;
  final bool? excludeDeleted;
  final int? parentId;
  final bool? isCollection;

  // Client-side filters (applied after fetch)
  final dynamic pinFilter; // null, NotNullValue, or specific value

  // Pagination
  final int? page;
  final int? pageSize;

  // Other filters not yet supported
  final Map<String, dynamic> otherFilters;
}

/// Adapts StoreQuery to StoreManager.listEntities() parameters.
///
/// Handles conversion between StoreQuery's Map\<String, dynamic\> format
/// and DartSDK StoreManager's named parameters.
class QueryFilterAdapter {
  /// Adapt a StoreQuery to StoreManager parameters.
  static AdaptedQueryParams adaptQuery(StoreQuery<CLEntity>? query) {
    if (query == null || query.map.isEmpty) {
      return const AdaptedQueryParams();
    }

    final map = query.map;

    // Extract special filters
    final idFilter = map['id'] as int?;
    final labelFilter = map['label'] as String?;

    // Extract server-side filters
    final md5 = map['md5'] as String?;
    final mimeType = map['mimeType'] as String?;
    final type = map['type'] as String?;
    final width = map['width'] as int?;
    final height = map['height'] as int?;
    final fileSizeMin = map['fileSizeMin'] as int?;
    final fileSizeMax = map['fileSizeMax'] as int?;
    final dateFrom = map['dateFrom'] as int?;
    final dateTo = map['dateTo'] as int?;

    // Convert boolean filters (0/1 to bool)
    final isDeletedInt = map['isDeleted'] as int?;
    final excludeDeleted = isDeletedInt != null ? isDeletedInt == 0 : null;

    final parentId = map['parentId'] as int?;

    final isCollectionInt = map['isCollection'] as int?;
    final isCollection = isCollectionInt != null ? isCollectionInt != 0 : null;

    // Client-side filters
    final pinFilter = map['pin']; // Can be null, NotNullValue, or string

    // Pagination
    final page = map['page'] as int?;
    final pageSize = map['pageSize'] as int?;

    // Collect unsupported filters
    final supportedKeys = {
      'id',
      'label',
      'md5',
      'mimeType',
      'type',
      'width',
      'height',
      'fileSizeMin',
      'fileSizeMax',
      'dateFrom',
      'dateTo',
      'isDeleted',
      'parentId',
      'isCollection',
      'pin',
      'page',
      'pageSize',
      'isHidden', // Handled separately - returns empty list
    };
    final otherFilters = Map<String, dynamic>.fromEntries(
      map.entries.where((e) => !supportedKeys.contains(e.key)),
    );

    return AdaptedQueryParams(
      idFilter: idFilter,
      labelFilter: labelFilter,
      md5: md5,
      mimeType: mimeType,
      type: type,
      width: width,
      height: height,
      fileSizeMin: fileSizeMin,
      fileSizeMax: fileSizeMax,
      dateFrom: dateFrom,
      dateTo: dateTo,
      excludeDeleted: excludeDeleted,
      parentId: parentId,
      isCollection: isCollection,
      pinFilter: pinFilter,
      page: page,
      pageSize: pageSize,
      otherFilters: otherFilters,
    );
  }
}
