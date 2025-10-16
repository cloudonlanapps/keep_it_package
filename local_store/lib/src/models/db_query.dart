import 'package:cl_basic_types/cl_basic_types.dart';
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
    Set<String> validColumns, [
    StoreQuery<T>? query,
  ]) {
    final whereParts = <String>[];
    final params = <dynamic>[];

    if (query != null) {
      for (final query in query.map.entries) {
        final key = query.key;
        final value = query.value;
        if (validColumns.contains(key)) {
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

    final whereClause = whereParts.isNotEmpty
        ? 'WHERE ${whereParts.join(' AND ')}'
        : '';
    final sql = 'SELECT * FROM $table $whereClause';

    return DBQuery<T>(
      sql: sql,
      parameters: params,
    );
  }

  final String sql;
  final Set<String> triggerOnTables;
  final List<Object?>? parameters;
}
