import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart'
    show CLLogger, TimeStampExtension, ValueGetter;
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
      final pagedResult = await entityStore.getAll(query);
      return ViewerEntities(
        pagedResult.items
            .map(
              (entityFromDB) =>
                  StoreEntity(clEntity: entityFromDB, clStore: this),
            )
            .toList(),
        pagination: pagedResult.pagination,
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
      final tempFile = File(createTempFile(ext: entity.extension ?? 'bin'));
      log(
        'Moving entity ${entity.id} from ${entity.store.label} to ${targetStore.label}',
      );

      StoreEntity? targetEntity;
      try {
        // 1. Download source to temp
        log('Step 1: Downloading content to ${tempFile.path}...');
        final downloaded = await entity.store.entityStore.download(
          entity.clEntity,
          tempFile,
        );
        if (!downloaded) {
          throw Exception('Failed to download content from message source');
        }
        log('Download successful.');

        // 2. Create in target (Upload)
        try {
          log('Step 2: Uploading/Creating media in target store...');
          targetEntity = await (await targetStore.createMedia(
            label: () => entity.label,
            description: () => entity.description,
            parentCollection: targetCollection.clEntity,
            mediaFile: CLMediaFile(
              path: tempFile.path,
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
          ))?.dbSave(tempFile.path);
        } catch (e) {
          log(
            'Create/Upload failed with error: $e. Attempting recovery check...',
          );
          // Fallthrough to verification step
        }

        // 3. Verify
        if (targetEntity == null) {
          log(
            'Target entity is null after creation. Checking if it exists in target store...',
          );
          // Recovery check: Look for the entity by MD5 in the target store
          final existing = await targetStore.get(md5: entity.md5);
          if (existing != null) {
            // Validate file size to ensure it's not a partial upload (if possible)
            // Note: dbSave might not have happened, so we check if the remote entity
            // *looks* correct.
            if (existing.fileSize == entity.fileSize) {
              log(
                'Recovery successful: Entity found in target store with matching file size.',
              );
              targetEntity = existing;
            } else {
              log(
                'Recovery failed: Entity found due to md5 match but file size mismatch '
                '(${existing.fileSize} vs ${entity.fileSize}).',
              );
            }
          } else {
            log('Recovery failed: Entity not found in target store.');
          }
        }

        // 4. Delete Source & cleanup
        if (targetEntity != null) {
          log(
            'Step 3: Verification successful (new ID: ${targetEntity.id}). Deleting from source...',
          );
          await entity.delete();
          log('Source entity deleted.');
          updated = targetEntity;
        } else {
          throw Exception(
            'Failed to create entity in target store (Verification failed).',
          );
        }
      } catch (e, st) {
        log('Error during move: $e\n$st');
        rethrow;
      } finally {
        // 5. Cleanup
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
          log('Temporary file cleaned up.');
        }
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

        try {
          final item = await getValidMediaFile(
            mediaFile,
            downloadDirectory: Directory(tempFilePath),
          ); // May be wrong?

          if (item != null) {
            Future<bool> processSupportedMediaContent() async {
              log(
                'Processing media file: ${item.identity} (type: ${item.type})',
              );
              if ([CLMediaType.image, CLMediaType.video].contains(item.type)) {
                final mediaInDB = await get(md5: item.md5);
                if (mediaInDB != null) {
                  log('Media found in DB: ${item.md5}');
                  existingEntities.add(mediaInDB);
                  return true;
                } else {
                  log('Media not in DB, creating new entity...');
                  final newEntity = await createMedia(
                    mediaFile: item,
                  );
                  if (newEntity != null) {
                    log('Entity created, saving to DB...');
                    final saved = await newEntity.dbSave(item.path);
                    if (saved != null) {
                      log('Entity saved to DB successfully.');
                      newEntities.add(saved);
                      return true;
                    } else {
                      log('Failed to save entity to DB.');
                    }
                  } else {
                    log('Failed to create media entity.');
                  }
                }
              } else {
                log('Unsupported media type for processing: ${item.type}');
              }
              return false;
            }

            if (!(await processSupportedMediaContent())) {
              invalidContent.add(mediaFile);
            }
          } else {
            invalidContent.add(mediaFile);
          }
        } catch (e, st) {
          log('Error processing file ${mediaFile.identity}: $e\n$st');
          invalidContent.add(mediaFile);
        }
      }
      yield const Progress(
        currentItem: 'processed all files',
        fractCompleted: 1,
      );
    } catch (e, st) {
      log('Critical error in getValidMediaFiles loop: $e\n$st');
      // Should not happen often if inner try-catch works
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
