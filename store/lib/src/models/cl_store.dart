import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:meta/meta.dart';

import 'cl_logger.dart';

import 'entity_store.dart';
import 'progress.dart';
import 'store_entity.dart';
import 'store_query.dart';

class ClStoreInterface {}

@immutable
class CLStore with CLLogger {
  const CLStore({
    required this.store,
    required this.tempFilePath,
    this.tempCollectionName = '*** Recently Captured',
  });
  final EntityStore store;
  final String tempCollectionName;
  final String tempFilePath;

  @override
  String get logPrefix => 'CLStore';
  String get label => store.storeURL.label ?? store.storeURL.name;

  CLStore copyWith({
    EntityStore? store,
    String? tempCollectionName,
    String? tempFilePath,
  }) {
    return CLStore(
      store: store ?? this.store,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
      tempFilePath: tempFilePath ?? this.tempFilePath,
    );
  }

  @override
  String toString() =>
      'CLStore(store: $store, tempCollectionName: $tempCollectionName, tempFilePath: $tempFilePath)';

  @override
  bool operator ==(covariant CLStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.tempCollectionName == tempCollectionName &&
        other.tempFilePath == tempFilePath;
  }

  @override
  int get hashCode =>
      store.hashCode ^ tempCollectionName.hashCode ^ tempFilePath.hashCode;

  Future<StoreEntity?> dbSave(
    StoreEntity entity, {
    String? path,
  }) async {
    final saved = await store.upsert(entity.data, path: path);
    if (saved == null) {
      return null;
    }
    return StoreEntity(entity: saved, store: this);
  }

  Future<bool> delete(int id) async {
    final entity = await store.getByID(id);

    if (entity == null) {
      return false;
    }
    return store.delete(entity);
  }

  // This function should not be exposed, and its only to detect
  // if we have duplicate.
  Future<StoreEntity?> get({String? md5, String? label}) async {
    final entityFromDB = await store.get(md5: md5, label: label);
    if (entityFromDB == null) {
      return null;
    }
    return StoreEntity(
      entity: entityFromDB,
      store: this,
    );
  }

  Future<ViewerEntities> getAll([StoreQuery<CLEntity>? query]) async {
    try {
      final entititesFromDB = await store.getAll(query);
      return ViewerEntities(entititesFromDB
          .cast<CLEntity>()
          .map(
            (entityFromDB) => StoreEntity(entity: entityFromDB, store: this),
          )
          .toList());
    } catch (e, st) {
      log('$e $st');
      rethrow;
    }
  }

  Future<StoreEntity?> createCollection({
    required String label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    final collectionInDB = await store.get(label: label);

    if (collectionInDB != null && collectionInDB.id != null) {
      if (!collectionInDB.isCollection) {
        throw Exception(
          'Entity with label $label is not a collection.',
        );
      }
      if (strategy == UpdateStrategy.skip) {
        return StoreEntity(entity: collectionInDB, store: this);
      } else {
        return updateCollection(
          collectionInDB,
          description: description,
          parentId: parentId,
          strategy: strategy,
        );
      }
    }

    return StoreEntity(
      entity: CLEntity.collection(
        label: label,
        description: description?.call(),
        parentId: parentId?.call(),
      ),
      store: this,
    );
  }

  Future<CLEntity> getTempCollection() async {
    final CLEntity? item;
    final temp = await createCollection(label: tempCollectionName);

    item =
        (await (await temp?.updateWith(isHidden: () => true))?.dbSave())?.data;
    if (item == null) {
      throw Exception(
        'missing parent; failed to create a default collection',
      );
    }
    if (item.id == null) {
      throw Exception('failed to get id for temporary collection');
    }
    return item;
  }

  Future<StoreEntity> move(
      StoreEntity entity, StoreEntity targetCollection) async {
    final StoreEntity? updated;
    if (targetCollection.store == entity.store) {
      updated = await (await entity.updateWith(
        parentId: () => targetCollection.id!,
        isHidden: () => false,
      ))
          ?.dbSave();
    } else {
      final targetStore = targetCollection.store;

      updated = await (await targetStore.createMedia(
              label: () => entity.data.label,
              description: () => entity.data.description,
              parentCollection: targetCollection.data,
              mediaFile: CLMediaFile(
                  path: entity.mediaUri!.toFilePath(),
                  md5: entity.data.md5!,
                  fileSize: entity.data.fileSize!,
                  mimeType: entity.data.mimeType!,
                  type: CLMediaType.fromMIMEType(entity.data.type!),
                  fileSuffix: entity.data.extension!,
                  createDate: entity.data.createDate,
                  height: entity.data.height,
                  width: entity.data.width,
                  duration: entity.data.duration),
              strategy: UpdateStrategy.mergeAppend))
          ?.dbSave(entity.mediaUri!.toFilePath());
      if (updated != null) {
        final filePath = entity.mediaUri!.toFilePath();

        await entity.delete();
        await File(filePath).deleteIfExists();
      }
    }

    if (updated == null) {
      throw Exception('Failed to update item ${entity.id}');
    }
    return updated;
  }

  Future<StoreEntity?> createMedia(
      {required CLMediaFile mediaFile,
      ValueGetter<String?>? label,
      ValueGetter<String?>? description,
      UpdateStrategy strategy = UpdateStrategy.skip,
      CLEntity? parentCollection}) async {
    /* if (!store.isLocal) {
      throw Exception("Can't directly push media files into non-local servers");
    } */
    if (parentCollection != null) {
      if (!parentCollection.isCollection) {
        throw Exception('Parent entity must be a collection.');
      }
      if (parentCollection.id == null) {
        throw Exception("media can't be stored without valid parentId");
      }
    }
    final mediaInDB = await store.get(md5: mediaFile.md5);

    final CLEntity parent;

    if (parentCollection == null) {
      parent = await getTempCollection();
    } else {
      parent = parentCollection;
    }

    if (mediaInDB != null && mediaInDB.id != null) {
      if (strategy == UpdateStrategy.skip) {
        return StoreEntity(entity: mediaInDB, store: this);
      } else {
        return updateMedia(
          mediaInDB,
          label: label,
          description: description,
          parentId: () => parent.id!,
          strategy: strategy,
        );
      }
    }

    return StoreEntity(
      entity: CLEntity.media(
        label: label != null ? label() : null,
        description: description != null ? description() : null,
        parentId: parent.id,
        md5: mediaFile.md5,
        fileSize: mediaFile.fileSize,
        mimeType: mediaFile.mimeType,
        type: mediaFile.type.name,
        extension: mediaFile.fileSuffix,
        createDate: mediaFile.createDate,
        height: mediaFile.height,
        width: mediaFile.width,
        duration: mediaFile.duration,
        isDeleted: false,
      ),
      store: this,
      // path: mediaFile.path,
    );
  }

  Future<StoreEntity?> updateCollection(
    CLEntity entity, {
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) async {
    if (strategy == UpdateStrategy.skip) {
      throw Exception(
        'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
      );
    }

    if (entity.id != null) {
      final entityInDB = await store.getByID(entity.id!);
      if (entityInDB == null) {
        throw Exception('entity with id ${entity.id} not found');
      }
      if (!entityInDB.isCollection) {
        throw Exception('entity found, but it is not collection');
      }
    }
    if (!entity.isCollection) {
      throw Exception('Entity must be collections.');
    }

    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entity.id == parentIdValue) {
        throw Exception(
          'Parent ID cannot be the same of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        /// FIXME: Handle failure due to network
        final parent = await store.getByID(parentIdValue);
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    return StoreEntity(
      entity: entity.copyWith(
        label: label,
        description: description != null
            ? () => switch (strategy) {
                  UpdateStrategy.mergeAppend =>
                    '${entity.descriptionText}\n${description()}'.trim(),
                  UpdateStrategy.overwrite => description.call(),
                  UpdateStrategy.skip =>
                    throw Exception('UpdateStrategy.skip is not allowed'),
                }
            : null,
        parentId: parentId,
        isDeleted: isDeleted?.call(),
        isHidden: isHidden?.call(),
      ),
      store: this,
    );
  }

  Future<StoreEntity?> updateMedia(
    CLEntity entity, {
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) async {
    if (strategy == UpdateStrategy.skip) {
      throw Exception(
        'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
      );
    }

    if (entity.id != null) {
      final entityInDB = await store.getByID(entity.id!);
      if (entityInDB == null) {
        throw Exception('entity with id ${entity.id} not found');
      }
      if (entityInDB.isCollection) {
        throw Exception('entity found, but it is not media');
      }
    }

    if (entity.isCollection) {
      throw Exception(
        'Entities must be media.',
      );
    }
    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entity.id == parentIdValue) {
        throw Exception(
          'Parent ID cannot be the same of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        final parent = await store.getByID(parentIdValue);
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    return StoreEntity(
      entity: entity.copyWith(
        label: label,
        description: description != null
            ? () => switch (strategy) {
                  UpdateStrategy.mergeAppend =>
                    '${entity.descriptionText}\n${description()}'.trim(),
                  UpdateStrategy.overwrite => description.call(),
                  UpdateStrategy.skip =>
                    throw Exception('UpdateStrategy.skip is not allowed'),
                }
            : null,
        parentId: parentId,
        isDeleted: isDeleted?.call(),
        isHidden: isHidden?.call(),
        pin: pin,
        md5: mediaFile == null ? null : () => mediaFile.md5,
        fileSize: mediaFile == null ? null : () => mediaFile.fileSize,
        mimeType: mediaFile == null ? null : () => mediaFile.mimeType,
        type: mediaFile == null ? null : () => mediaFile.type.name,
        extension: mediaFile == null ? null : () => mediaFile.fileSuffix,
        createDate: mediaFile == null ? null : () => mediaFile.createDate,
        height: mediaFile == null ? null : () => mediaFile.height,
        width: mediaFile == null ? null : () => mediaFile.width,
        duration: mediaFile == null ? null : () => mediaFile.duration,
      ),
      store: this,
      // path: mediaFile?.path,
    );
  }

  Stream<Progress> getValidMediaFiles(
      {required List<CLMediaContent> contentList,
      required Future<CLMediaFile?> Function(CLMediaContent mediaContent,
              {required Directory downloadDirectory})
          getValidMediaFile,
      void Function({
        required ViewerEntities existingEntities,
        required ViewerEntities newEntities,
        required List<CLMediaContent> invalidContent,
      })? onDone}) async* {
    /// Valid Media can only be pushed into a local store
    /// Rationale:
    ///   handling the id for server and managing the network situation when
    ///   processing the media files is complicated.
    ///   We always receive the content into a local server and then push to
    ///   the appropriate server.
    if (store.storeURL.scheme != 'local') {
      throw Exception("Can't directly push media files into non-local servers");
    }
    final existingEntities = <StoreEntity>[];
    final newEntities = <StoreEntity>[];
    final invalidContent = <CLMediaContent>[];
    try {
      for (final (i, mediaFile) in contentList.indexed) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        yield Progress(
          currentItem: 'processing "${mediaFile.identity}"',
          fractCompleted: (i + 1) / contentList.length,
        );

        final item = await getValidMediaFile(mediaFile,
            downloadDirectory: Directory(tempFilePath)); // May be wrong?

        if (item != null) {
          Future<bool> processSupportedMediaContent() async {
            if ([CLMediaType.image, CLMediaType.video].contains(item.type)) {
              /// FIXME: Handle failure due to network
              final mediaInDB = await get(md5: item.md5);
              if (mediaInDB != null) {
                existingEntities.add(mediaInDB);
                return true;
              } else {
                final newEntity = await createMedia(
                  mediaFile: item,
                );
                if (newEntity != null) {
                  final saved = await newEntity.dbSave(item.path);
                  if (saved != null) {
                    newEntities.add(saved);
                    return true;
                  }
                }
              }
            }
            return false;
          }

          if (await processSupportedMediaContent() == false) {
            invalidContent.add(mediaFile);
          }
        } else {
          invalidContent.add(mediaFile);
        }
      }
      yield const Progress(
        currentItem: 'processed all files',
        fractCompleted: 1,
      );
    } catch (e) {
      // Need to check and add items into invalidContent
    }
    onDone?.call(
      existingEntities: ViewerEntities(existingEntities),
      newEntities: ViewerEntities(newEntities),
      invalidContent: invalidContent,
    );
  }

  String createTempFile({required String ext}) {
    final fileBasename =
        'keep_it_temp_${DateTime.now().millisecondsSinceEpoch}';

    return '$tempFilePath/$fileBasename.$ext';
  }
}
