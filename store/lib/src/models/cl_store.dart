import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'entity_store.dart';
import 'progress.dart';
import 'store_entity.dart';
import 'store_query.dart';

class ClStoreInterface {}

@immutable
class CLStore with CLLogger {
  const CLStore({
    required this.entityStore,
    required this.tempFilePath,
    this.tempCollectionName = '*** Recently Captured',
  });
  final EntityStore entityStore;
  final String tempCollectionName;
  final String tempFilePath;

  @override
  String get logPrefix => 'CLStore';
  String get label =>
      entityStore.config.label ?? entityStore.config.displayName;

  CLStore copyWith({
    EntityStore? entityStore,
    String? tempCollectionName,
    String? tempFilePath,
  }) {
    return CLStore(
      entityStore: entityStore ?? this.entityStore,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
      tempFilePath: tempFilePath ?? this.tempFilePath,
    );
  }

  @override
  String toString() =>
      'CLStore(entityStore: $entityStore, tempCollectionName: $tempCollectionName, tempFilePath: $tempFilePath)';

  @override
  bool operator ==(covariant CLStore other) {
    if (identical(this, other)) return true;

    return other.entityStore == entityStore &&
        other.tempCollectionName == tempCollectionName &&
        other.tempFilePath == tempFilePath;
  }

  @override
  int get hashCode =>
      entityStore.hashCode ^
      tempCollectionName.hashCode ^
      tempFilePath.hashCode;

  Future<StoreEntity?> dbSave(
    StoreEntity entity, {
    String? path,
  }) async {
    final saved = await entityStore.upsert(entity.clEntity, path: path);
    if (saved == null) {
      return null;
    }
    return StoreEntity(clEntity: saved, clStore: this);
  }

  Future<bool> delete(int id) async {
    final entity = await entityStore.getByID(id);

    if (entity == null) {
      return false;
    }
    return entityStore.delete(entity);
  }

  // This function should not be exposed, and its only to detect
  // if we have duplicate.
  Future<StoreEntity?> get({String? md5, String? label}) async {
    final entityFromDB = await entityStore.get(md5: md5, label: label);
    if (entityFromDB == null) {
      return null;
    }
    return StoreEntity(
      clEntity: entityFromDB,
      clStore: this,
    );
  }

  Future<ViewerEntities> getAll([StoreQuery<CLEntity>? query]) async {
    try {
      final entititesFromDB = await entityStore.getAll(query);
      return ViewerEntities(
        entititesFromDB
            .cast<CLEntity>()
            .map(
              (entityFromDB) =>
                  StoreEntity(clEntity: entityFromDB, clStore: this),
            )
            .toList(),
      );
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
    final collectionInDB = await entityStore.get(label: label);

    if (collectionInDB != null && collectionInDB.id != null) {
      if (!collectionInDB.isCollection) {
        throw Exception(
          'Entity with label $label is not a collection.',
        );
      }
      if (strategy == UpdateStrategy.skip) {
        return StoreEntity(clEntity: collectionInDB, clStore: this);
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
      clEntity: CLEntity.collection(
        label: label,
        description: description?.call(),
        parentId: parentId?.call(),
      ),
      clStore: this,
    );
  }

  Future<CLEntity> getTempCollection() async {
    final CLEntity? item;
    final temp = await createCollection(label: tempCollectionName);

    item = (await (await temp?.updateWith(
      isHidden: () => true,
    ))?.dbSave())?.clEntity;
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
    StoreEntity entity,
    StoreEntity targetCollection,
  ) async {
    final StoreEntity? updated;
    if (targetCollection.store.entityStore == entity.store.entityStore) {
      updated = await (await entity.updateWith(
        parentId: () => targetCollection.id!,
        isHidden: () => false,
      ))?.dbSave();
    } else {
      final targetStore = targetCollection.store;

      updated = await (await targetStore.createMedia(
        label: () => entity.label,
        description: () => entity.description,
        parentCollection: targetCollection.clEntity,
        mediaFile: CLMediaFile(
          path: entity.mediaUri!.toFilePath(),
          md5: entity.md5!,
          fileSize: entity.fileSize!,
          mimeType: entity.mimeType!,
          type: CLMediaType.fromMIMEType(entity.type!),
          fileSuffix: entity.extension!,
          createDate: entity.createDate,
          height: entity.height,
          width: entity.width,
          duration: entity.duration,
        ),
        strategy: UpdateStrategy.mergeAppend,
      ))?.dbSave(entity.mediaUri!.toFilePath());
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

  Future<StoreEntity?> createMedia({
    required CLMediaFile mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
    CLEntity? parentCollection,
  }) async {
    /* if (!entityStore.isLocal) {
      throw Exception("Can't directly push media files into non-local servers");
    } */
    if (parentCollection != null) {
      if (!parentCollection.isCollection) {
        throw Exception('Parent entity must be a collection.');
      }
      if (parentCollection.id == null) {
        throw Exception("media can't be entityStored without valid parentId");
      }
    }
    final mediaInDB = await entityStore.get(md5: mediaFile.md5);

    final CLEntity parent;

    if (parentCollection == null) {
      parent = await getTempCollection();
    } else {
      parent = parentCollection;
    }

    if (mediaInDB != null && mediaInDB.id != null) {
      if (strategy == UpdateStrategy.skip) {
        return StoreEntity(clEntity: mediaInDB, clStore: this);
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
      clEntity: CLEntity.media(
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
      clStore: this,
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
      final entityInDB = await entityStore.getByID(entity.id!);
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
        final parent = await entityStore.getByID(parentIdValue);
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    return StoreEntity(
      clEntity: entity.copyWith(
        label: label,
        description: description != null
            ? () => switch (strategy) {
                UpdateStrategy.mergeAppend =>
                  '${entity.descriptionText}\n${description()}'.trim(),
                UpdateStrategy.overwrite => description.call(),
                UpdateStrategy.skip => throw Exception(
                  'UpdateStrategy.skip is not allowed',
                ),
              }
            : null,
        parentId: parentId,
        isDeleted: isDeleted?.call(),
        isHidden: isHidden?.call(),
      ),
      clStore: this,
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
      final entityInDB = await entityStore.getByID(entity.id!);
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
        final parent = await entityStore.getByID(parentIdValue);
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    return StoreEntity(
      clEntity: entity.copyWith(
        label: label,
        description: description != null
            ? () => switch (strategy) {
                UpdateStrategy.mergeAppend =>
                  '${entity.descriptionText}\n${description()}'.trim(),
                UpdateStrategy.overwrite => description.call(),
                UpdateStrategy.skip => throw Exception(
                  'UpdateStrategy.skip is not allowed',
                ),
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
      clStore: this,
      // path: mediaFile?.path,
    );
  }

  Stream<Progress> getValidMediaFiles({
    required List<CLMediaContent> contentList,
    required Future<CLMediaFile?> Function(
      CLMediaContent mediaContent, {
      required Directory downloadDirectory,
    })
    getValidMediaFile,
    void Function({
      required ViewerEntities existingEntities,
      required ViewerEntities newEntities,
      required List<CLMediaContent> invalidContent,
    })?
    onDone,
  }) async* {
    /// Valid Media can only be pushed into a local entityStore
    /// Rationale:
    ///   handling the id for server and managing the network situation when
    ///   processing the media files is complicated.
    ///   We always receive the content into a local server and then push to
    ///   the appropriate server.
    if (!entityStore.isLocal) {
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

        final item = await getValidMediaFile(
          mediaFile,
          downloadDirectory: Directory(tempFilePath),
        ); // May be wrong?

        if (item != null) {
          Future<bool> processSupportedMediaContent() async {
            if ([CLMediaType.image, CLMediaType.video].contains(item.type)) {
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

          if (!(await processSupportedMediaContent())) {
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
    final fileBasename = 'keep_it_temp_${DateTime.now().utcTimeStamp}';

    return '$tempFilePath/$fileBasename.$ext';
  }
}
