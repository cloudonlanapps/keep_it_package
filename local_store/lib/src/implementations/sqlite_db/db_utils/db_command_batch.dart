import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnMap;
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'db_command.dart';

@immutable
class DBBatchCommand {
  const DBBatchCommand(this.commands);

  factory DBBatchCommand.insert(
    List<Map<String, dynamic>> list, {
    required String table,
    bool autoIncrementId = true,
    bool ignore = false,
  }) {
    return DBBatchCommand(
      list
          .map(
            (e) => DBCommand.insert(
              e,
              table: table,
              autoIncrementId: autoIncrementId,
              ignore: ignore,
            ),
          )
          .toList(),
    ).merge();
  }
  factory DBBatchCommand.update(
    List<Map<String, dynamic>> list, {
    required String table,
  }) {
    return DBBatchCommand(
      list
          .map(
            (e) => DBCommand.update(
              e,
              table: table,
            ),
          )
          .toList(),
    ).merge();
  }
  factory DBBatchCommand.delete(
    List<Map<String, dynamic>> list, {
    required String table,
    List<String>? identifiers,
  }) {
    return DBBatchCommand(
      list
          .map(
            (e) => DBCommand.delete(
              e,
              table: table,
              identifiers: identifiers,
            ),
          )
          .toList(),
    ).merge();
  }

  static Future<DBBatchCommand> upsertAsync(
    List<Map<String, dynamic>> list, {
    required String table,
    required Future<List<int>> Function(List<int> id) getPresentIdList,
    bool autoIncrementId = true,
    bool ignore = false,
  }) async {
    final idsPresent = await getPresentIdList(
      list.where((e) => e.hasID).map((e) => e.id!).toList(),
    );
    final items2Update = list.where((e) => idsPresent.contains(e.id)).toList();
    final items2insert = list.where((e) => !idsPresent.contains(e.id)).toList();

    return DBBatchCommand([
      ...items2Update.map(
        (e) => DBCommand.update(
          e,
          table: table,
        ),
      ),
      ...items2insert.map(
        (e) => DBCommand.insert(
          e,
          table: table,
          autoIncrementId: autoIncrementId,
          ignore: ignore,
        ),
      ),
    ]);
  }

  final List<DBCommand> commands;

  DBBatchCommand merge() {
    final map = <String, DBCommand>{};
    for (final item in commands) {
      map.putIfAbsent(item.sql, () => item).mergeParameters(item);
    }

    return DBBatchCommand(map.values.toList());
  }

  Future<bool> execute(SqliteWriteContext tx) async {
    for (final cmd in commands) {
      if (!await cmd.execute(tx)) return false;
    }
    return true;
  }
}
