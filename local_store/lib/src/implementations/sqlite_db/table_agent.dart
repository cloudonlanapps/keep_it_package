import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../models/db_query.dart';
import 'db_utils/db_command.dart';

@immutable
class SQLiteTableAgent<T> with CLLogger {
  const SQLiteTableAgent({
    required this.db,
    required this.table,
    required this.fromMap,
    required this.toMap,
    required this.dbQueryForItem,
    required this.getUniqueColumns,
    required this.validColumns,
    this.autoIncrementId = true,
  });

  final SqliteDatabase db;
  final String table;
  final T Function(Map<String, dynamic>)? fromMap;
  final Map<String, dynamic>? Function(T obj) toMap;
  final Future<DBQuery<T>> Function(T obj) dbQueryForItem;
  final List<String> Function(T obj) getUniqueColumns;
  final Set<String> validColumns;
  final bool autoIncrementId;

  Future<bool> updateFromMap(
    SqliteWriteContext tx,
    Map<String, dynamic> map,
  ) async {
    final filteredMap = {
      for (final key in map.keys)
        if (validColumns.contains(key)) key: map[key],
    };
    return DBCommand.update(filteredMap, table: table).execute(tx);
  }

  Future<T?> readBack(SqliteWriteContext tx, T obj) async =>
      get(tx, await dbQueryForItem(obj));

  Future<T?> upsert(
    SqliteWriteContext tx,
    T obj, {
    bool ignore = false,
  }) async {
    final T? result;
    final map = toMap(obj);

    log('upsert to $table: $obj');

    // Filter the map to include only valid columns
    final filteredMap = {
      for (final key in map!.keys)
        if (validColumns.contains(key)) key: map[key],
    };

    if (ignore) {
      if (filteredMap.isEmpty) return null;
      await DBCommand.insert(
        filteredMap,
        table: table,
        ignore: ignore,
        autoIncrementId: autoIncrementId,
      ).execute(tx);
      result = await readBack.call(tx, obj);
    } else {
      if (filteredMap.isEmpty) {
        throw Exception("couldn't not get map for the given object");
      }

      final bool insertStatus;

      insertStatus = await DBCommand.upsert(
        tx,
        filteredMap,
        autoIncrementId: autoIncrementId,
        table: table,
        getItemByColumnValue: (key, value) async {
          return (await tx.getAll('SELECT * FROM $table WHERE $key = ?', [
            value,
          ])).firstOrNull;
        },
        uniqueColumn: getUniqueColumns(obj),
      );

      if (!insertStatus) {
        throw Exception("couldn't not upsert");
      }

      result = await readBack(tx, obj);
    }
    log('upsertNote: Done :  $result');
    return result;
  }

  Future<void> delete(
    SqliteWriteContext tx,
    T obj, {
    List<String>? identifier,
  }) async {
    final map = toMap(obj);
    if (map == null) return;

    final filteredMap = {
      for (final key in map.keys)
        if (validColumns.contains(key)) key: map[key],
    };

    await DBCommand.delete(
      filteredMap,
      table: table,
      identifiers: identifier,
    ).execute(tx);
  }

  Future<List<T>> upsertAll(
    SqliteWriteContext tx,
    List<T> objs, {
    required List<String> uniqueColumn,
  }) async {
    final updated = <T>[];
    for (final obj in objs) {
      try {
        updated.add(
          (await upsert(tx, obj)) as T,
        );
      } catch (e) {
        /** */
      }
    }
    return updated;
  }

  static Map<String, dynamic> fixedMap(Map<String, dynamic> map) {
    final updatedMap = <String, dynamic>{};
    const removeValues = ['null'];
    for (final e in map.entries) {
      final value = switch (e) {
        (final MapEntry<String, dynamic> _)
            when removeValues.contains(e.value) =>
          null,
        _ => e.value,
      };
      if (value != null) {
        updatedMap[e.key] = value;
      }
    }
    return updatedMap;
  }

  Future<List<T>> getAll(SqliteWriteContext tx, DBQuery<T> query) async {
    final sql = query.sql;
    final parameters = query.parameters;

    log('cmd: $sql, $parameters');

    final fectched = await tx.getAll(sql, parameters ?? []);
    final objs = fectched
        .map((e) => (fromMap != null) ? fromMap!(fixedMap(e)) : e as T)
        .where((e) => e != null)
        .map((e) => e! as T)
        .toList();
    log("read: ${objs.map((e) => e.toString()).join(', ')}");
    return objs;
  }

  Future<T?> get(SqliteWriteContext tx, DBQuery<T> query) async {
    final sql = query.sql;
    final parameters = query.parameters;

    log('cmd: $sql, $parameters');

    final obj = (await tx.getAll(sql, parameters ?? []))
        .map((e) => (fromMap != null) ? fromMap!(fixedMap(e)) : e as T)
        .firstOrNull;
    log('read $obj');
    return obj;
  }

  @override
  String get logPrefix => 'SQLiteTableAgent';
}

const _filePrefix = 'DB Write (internal): ';
bool _disableInfoLogger = false;

String? prefixedMsg(String msg) {
  if (!_disableInfoLogger) {
    return '$_filePrefix$msg';
  }
  return null;
}
