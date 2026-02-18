import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/persist_json.dart';

final internalJSONStoreprovider = FutureProvider<InternalJSONStore>((
  ref,
) async {
  return InternalJSONStore.create();
});

class InternalJSONStore with CLLogger implements PersistJson {
  InternalJSONStore(this.db);
  final SqliteDatabase db;

  static final migrations = SqliteMigrations()
    ..add(
      SqliteMigration(1, (tx) async {
        await tx.execute('''
          CREATE TABLE IF NOT EXISTS CLMediaViewersState (
            key TEXT   NOT NULL UNIQUE,
            json TEXT)
        ''');
      }),
    );

  static Future<InternalJSONStore> create({
    String dbName = 'cl_media_viewer_context.db',
  }) async {
    final databasesPath = await getApplicationSupportDirectory();
    final dbpath = p.join(databasesPath.path, dbName);
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    //log('Create a internal DB at $dbpath');
    return InternalJSONStore(db);
  }

  @override
  Future<void> save(String key, String json) async {
    await db.writeTransaction(
      (tx) => tx.execute(
        'INSERT OR REPLACE INTO CLMediaViewersState (key, json) VALUES (?, ?)',
        [key, json],
      ),
    );
  }

  @override
  Future<String> load(String key, String defaultJson) async {
    try {
      final result = await db.get(
        'SELECT json FROM CLMediaViewersState WHERE key = ?',
        [key],
      );
      if (result.isEmpty) {
        return defaultJson;
      } else {
        return result['json'] as String;
      }
    } catch (e) {
      return defaultJson;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await db.execute('DELETE FROM users WHERE key = ?', [key]);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String get logPrefix => 'InternalJSONStore';
}
