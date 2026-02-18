import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import '../../models/db_query.dart';
import 'table_agent.dart';

mixin SQLiteDBTableMixin<T> {
  Future<T?> dbGet(
    SqliteWriteContext tx,
    SQLiteTableAgent<T> agent,
    StoreQuery<T>? query, {
    String select = '*',
  }) async {
    final dbQuery = DBQuery.fromStoreQuery(
      agent.table,
      agent.validColumns,
      query,
      select: select,
    );
    return agent.get(tx, dbQuery);
  }

  Future<List<T>> dbGetAll(
    SqliteWriteContext tx,
    SQLiteTableAgent<T> agent,
    StoreQuery<T>? query, {
    String select = '*',
  }) async {
    final dbQuery = DBQuery.fromStoreQuery(
      agent.table,
      agent.validColumns,
      query,
      select: select,
    );
    return agent.getAll(tx, dbQuery);
  }

  Future<T?> dbUpsert(
    SqliteWriteContext tx,
    SQLiteTableAgent<T> agent,
    T item,
  ) {
    return agent.upsert(tx, item);
  }

  Future<void> dbDelete(
    SqliteWriteContext tx,
    SQLiteTableAgent<T> agent,
    T item,
  ) {
    return agent.delete(tx, item);
  }
}
