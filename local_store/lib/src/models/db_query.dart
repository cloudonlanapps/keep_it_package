import 'dart:developer';

import 'package:cl_extensions/cl_extensions.dart' show NotNullValue;
import 'package:meta/meta.dart';
import 'package:store/store.dart';

@immutable
class DBQuery<T> {
  const DBQuery({
    required this.sql,
    this.triggerOnTables = const {},
    this.parameters,
  });
  factory DBQuery.fromStoreQuery(
    String table,
    Set<String> validColumns,
    StoreQuery<T>? query, {
    String select = '*',
  }) {
    final whereParts = <String>[];
    final params = <dynamic>[];

    if (query != null) {
      for (final queryEntry in query.map.entries) {
        final key = queryEntry.key;
        final value = queryEntry.value;
        if (validColumns.contains(key)) {
          if (key == 'parentId' && (value == null || value == 0)) {
            whereParts.add('($key IS NULL OR $key = 0)');
          } else {
            switch (value as Object?) {
              case null:
                whereParts.add('$key IS NULL');
              case (final List<dynamic> e) when e.isNotEmpty:
                whereParts.add(
                  '$key IN (${List.filled(e.length, '?').join(', ')})',
                );
                params.addAll(e);
              case (final NotNullValue _):
                whereParts.add('$key IS NOT NULL');
              default:
                whereParts.add('$key IS ?');
                params.add(value);
            }
          }
        }
      }
    }

    final whereClause = whereParts.isNotEmpty
        ? 'WHERE ${whereParts.join(' AND ')}'
        : '';

    var sql = 'SELECT $select FROM $table $whereClause';

    // Add pagination (only if select is '*', meaning it's a data query, not count)
    // Actually, let's look at the select param. If it's COUNT(*), we ignore pagination.
    if (query != null && !select.toUpperCase().contains('COUNT')) {
      final limit = query.pageSize;
      final offset = (query.page - 1) * query.pageSize;
      sql += ' LIMIT ? OFFSET ?';
      params
        ..add(limit)
        ..add(offset);
    }

    log('DBQuery.fromStoreQuery: $sql, params: $params');

    return DBQuery<T>(
      sql: sql,
      parameters: params,
    );
  }

  final String sql;
  final Set<String> triggerOnTables;
  final List<Object?>? parameters;
}
