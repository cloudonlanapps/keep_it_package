// ignore_for_file: use_null_aware_elements, because we don't weant even key

import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import '../implementations/sqlite_db.dart' show createSQLiteDBInstance;
import '../implementations/sqlite_db/db_store.dart';
import '../implementations/sqlite_db/db_table_mixin.dart';
import '../implementations/sqlite_db/table_agent.dart';
import 'db_query.dart';
import 'local_service_location_config.dart';

@immutable
class LocalSQLiteEntityStore extends EntityStore
    with SQLiteDBTableMixin<CLEntity>, CLLogger {
  LocalSQLiteEntityStore(
    this.agent, {
    required super.config,
    required this.mediaPath,
    required this.previewPath,
    required this.generatePreview,
  });
  final SQLiteTableAgent<CLEntity> agent;
  final String mediaPath;
  final String previewPath;
  final Future<String> Function(
    String mediaPath, {
    required String previewPath,
    required int dimension,
  })
  generatePreview;

  @override
  bool get isAlive => true;

  @override
  Future<bool> delete(CLEntity item) async {
    // First remove files (to ensure complete removal as requested)
    await deleteMediaFiles(item);

    Future<void> cb(SqliteWriteContext tx) async {
      await dbDelete(tx, agent, item);
    }

    try {
      await agent.db.writeTransaction(cb);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> download(CLEntity item, File targetFile) async {
    final sourcePath = absoluteMediaPath(item);
    if (sourcePath == null) {
      log('Download failed: Source path is null for entity ${item.id}');
      return false;
    }

    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      log('Download failed: Source file does not exist at $sourcePath');
      return false;
    }

    try {
      await sourceFile.copy(targetFile.path);
      log('Downloaded (copied) local file to ${targetFile.path}');
      return true;
    } catch (e) {
      log('Error downloading (copying) file: $e');
      return false;
    }
  }

  static const _childrenCountSubQuery =
      '(SELECT COUNT(*) FROM Entity E2 WHERE E2.parentId = Entity.id AND E2.isDeleted = 0) as childrenCount';

  @override
  Future<CLEntity?> get({int? id, String? md5, String? label}) async {
    Future<CLEntity?> cb(SqliteWriteContext tx) async {
      final query = StoreQuery<CLEntity>({
        if (id != null) 'id': id,
        if (md5 != null) 'md5': md5,
        if (label != null) ...{'label': label, 'isCollection': 1},
      });
      return dbGet(
        tx,
        agent,
        query,
        select: '*, $_childrenCountSubQuery',
      );
    }

    return agent.db.writeTransaction(cb);
  }

  @override
  Future<CLEntity?> getByID(int id) async {
    return get(id: id);
  }

  @override
  Future<PagedResult<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    return agent.db.writeTransaction((tx) async {
      // 1. Get Total Count
      // We use a direct query for count since dbGetAll tries to map to CLEntity.
      final dbQueryForCount = DBQuery.fromStoreQuery(
        agent.table,
        agent.validColumns,
        query,
        select: 'COUNT(*) as count',
      );
      final countRows = await tx.getAll(
        dbQueryForCount.sql,
        dbQueryForCount.parameters ?? [],
      );
      final totalItems = (countRows.firstOrNull?['count'] as int?) ?? 0;

      // 2. Get Paginated Items
      final items = await dbGetAll(
        tx,
        agent,
        query,
        select: '*, $_childrenCountSubQuery',
      );

      // 3. Construct Metadata
      final pageSize = query?.pageSize ?? 20;
      final page = query?.page ?? 1;
      final totalPages = (totalItems / pageSize).ceil();

      return PagedResult(
        items: items,
        pagination: PaginationMetadata(
          page: page,
          pageSize: pageSize,
          totalItems: totalItems,
          totalPages: totalPages,
          hasNext: page < totalPages,
          hasPrev: page > 1,
        ),
      );
    });
  }

  String? absoluteMediaPath(CLEntity media) =>
      media.path == null ? null : '$mediaPath/${media.path}';

  String? absolutePreviewPath(CLEntity media) =>
      media.previewPath == null ? null : '$previewPath/${media.previewPath}';

  @override
  Uri? mediaUri(CLEntity media) {
    final filePath = absoluteMediaPath(media);
    if (filePath == null) return null;
    return Uri.file(filePath);
  }

  @override
  Uri? previewUri(CLEntity media) {
    final filePath = absolutePreviewPath(media);
    if (filePath == null) return null;
    return Uri.file(filePath);
  }

  Future<bool> createMediaFiles(
    CLEntity media,
    String path, {
    required Future<String> Function(
      String mediaPath, {
      required String previewPath,
      required int dimension,
    })
    generatePreview,
  }) async {
    final mediaPath = absoluteMediaPath(media);
    final previewPath = absolutePreviewPath(media);
    if (previewPath != null) {
      final previewDirPath = p.dirname(previewPath);
      Directory(previewDirPath).createSync(recursive: true);
    }
    if (mediaPath != null) {
      final f = File(mediaPath);
      final dirPath = p.dirname(f.path);
      Directory(dirPath).createSync(recursive: true);
      File(path).copySync(mediaPath);

      await generatePreview(
        mediaPath,
        previewPath: previewPath!,
        dimension: 640,
      );
      return File(mediaPath).existsSync() && File(previewPath).existsSync();
    }
    return false;
  }

  Future<bool> deleteMediaFiles(CLEntity media) async {
    final mediaPath = absoluteMediaPath(media);
    final previewPath = absolutePreviewPath(media);
    for (final path in [mediaPath, previewPath]) {
      if (path != null) {
        final f = File(path);
        if (f.existsSync()) {
          f.deleteSync();
        }
      }
    }
    return mediaPath != null && previewPath != null;
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) async {
    CLEntity? prev;
    CLEntity updated;

    final String? currentMediaPath;
    final String? prevMediaPath;

    try {
      prev = null;
      if (curr.id == null) {
        final timeNow = DateTime.now();
        updated = curr.copyWith(addedDate: timeNow, updatedDate: timeNow);
      } else {
        prev = await getByID(curr.id!);
        if (prev == null) {
          throw Exception('media with id ${curr.id} not found');
        }
        if ((prev.md5 == curr.md5) && path != null) {
          throw Exception('path is not expected');
        } else if ((prev.md5 != curr.md5) && path == null) {
          throw Exception('path expected as media changed');
        }
        if (curr.isSame(prev)) {
          // nothing to update!, avoid date change and send previous
          return prev;
        } else if (curr.isContentSame(prev)) {
          updated = curr.copyWith(
            updatedDate: DateTime.now(),
          );
        } else {
          // few items like, pin and hidden don't change the update date
          // they are just state
          updated = curr;
        }
      }

      final expectedPath = absoluteMediaPath(updated);
      if (expectedPath != null && File(expectedPath).existsSync()) {
        currentMediaPath = expectedPath;
      } else {
        currentMediaPath = null;
      }

      prevMediaPath = prev == null ? null : absoluteMediaPath(prev);
    } catch (e) {
      log('Error preparing upsert: $e');
      return prev;
    }

    Future<CLEntity?> cb(SqliteWriteContext tx) async {
      try {
        final parent = await dbGet(
          tx,
          agent,
          StoreQuery<CLEntity>({'id': updated.parentId}),
        );

        final entityFromDB = await dbUpsert(
          tx,
          agent,
          updated.copyWith(
            isHidden: updated.isHidden || (parent?.isHidden ?? false),
          ),
        );
        if (entityFromDB == null) throw Exception('failed to update DB');
        if (path != null) {
          // do we need to check this against prevMediaPath
          // if they are same, still this overwrites.
          await createMediaFiles(
            updated,
            path,
            generatePreview: generatePreview,
          );
        }
        // generate preview here

        return entityFromDB;
      } catch (e) {
        log('Transaction error: $e');
        rethrow;
      }
    }

    try {
      final saved = await agent.db.writeTransaction(cb);
      if (saved != null) {
        if (prev != null && !saved.isContentSame(prev)) {
          if (prevMediaPath != null && prevMediaPath != currentMediaPath) {
            await deleteMediaFiles(prev);
          }
        }
        return saved;
      }
    } catch (e) {
      log('Write transaction failed: $e');
      if (currentMediaPath != null && prevMediaPath != currentMediaPath) {
        await deleteMediaFiles(updated);
      }
    }
    return prev;
  }

  static Future<EntityStore> createStore(
    DBModel db, {
    required String identity,
    required LocalServiceLocationConfig locationConfig,
    required String mediaPath,
    required String previewPath,
    required Future<String> Function(
      String mediaPath, {
      required String previewPath,
      required int dimension,
    })
    generatePreview,
  }) async {
    const tableName = 'entity';
    final sqliteDB = db as SQLiteDB;
    final columnInfo = await db.db.execute('PRAGMA table_info($tableName)');
    final validColumns = columnInfo.map((row) => row['name'] as String).toSet();

    final agent = SQLiteTableAgent<CLEntity>(
      db: sqliteDB.db,
      table: 'Entity',
      fromMap: CLEntity.fromMap,
      toMap: (obj) => obj.toMap(),
      dbQueryForItem: (obj) async => DBQuery.fromStoreQuery(
        tableName,
        validColumns,
        Shortcuts.mediaQuery('ignore', obj), // We use this inside the server.
        select: '*, $_childrenCountSubQuery',
      ),
      getUniqueColumns: (obj) {
        return ['id', if (obj.isCollection) 'label' else 'md5'];
      },
      validColumns: validColumns,
    );

    return LocalSQLiteEntityStore(
      agent,
      config: locationConfig,
      mediaPath: mediaPath,
      previewPath: previewPath,
      generatePreview: generatePreview,
    );
  }

  @override
  String get logPrefix => 'LocalSQLiteEntityStore';
}

Future<EntityStore> createEntityStore(
  LocalServiceLocationConfig config, {
  required String storePath,
  required Future<String> Function(
    String mediaPath, {
    required String previewPath,
    required int dimension,
  })
  generatePreview,
}) async {
  final dbPath = p.join(storePath, 'db');
  final mediaPath = p.join(storePath, 'media');
  final previewPath = p.join(storePath, 'thumbnails');

  for (final path in [dbPath, mediaPath, previewPath]) {
    Directory(path).createSync(recursive: true);
  }

  final fullPath = p.join(dbPath, '${config.storePath}.db');
  final db = await createSQLiteDBInstance(fullPath);

  return switch (db) {
    (final SQLiteDB db) => LocalSQLiteEntityStore.createStore(
      db,
      identity: config.storePath,
      locationConfig: config,
      mediaPath: mediaPath,
      previewPath: previewPath,
      generatePreview: generatePreview,
    ),
    _ => throw Exception('Unsupported DB'),
  };
}
