import 'package:cl_basic_types/cl_basic_types.dart';

import 'package:flutter/material.dart';
import 'package:store/store.dart';

class DialogService {
  static Future<bool?> template(
    BuildContext context, {
    required String title,
    required String message,
    ViewerEntities? entity,
  }) async =>
      showDialog<bool?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          alignment: Alignment.center,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* if (entity != null && entity.entities.isNotEmpty)
                switch (entity.entities.first) {
                  final StoreEntity e when !e.isCollection => SizedBox.square(
                      dimension: 100,
                      child: CLMediaCollage.byMatrixSize(
                        entity.length,
                        hCount: 3,
                        vCount: 3,
                        itemBuilder: (context, index) {
                          return EntityPreview(
                            item: entity.entities[index] as StoreEntity,
                            parentId: entity.entities[index].parentId,
                            entities: const ViewerEntities([]),
                          );
                        },
                        whenNopreview: const Center(),
                      ),
                    ),
                  _ => Container()
                }, */ // FIXME [LATER] preview
              Text(
                message,
              ),
            ],
          ),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () async => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      );

  static Future<bool?> deleteEntity(
    BuildContext context, {
    required StoreEntity entity,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: entity.isCollection
            ? 'Are you sure you want to delete '
                '"${entity.label}" and its content?'
            : 'Are you sure you want to delete '
                'this ${entity.mediaType}?',
        entity: ViewerEntities([entity]),
      );

  static Future<bool?> deleteMultipleEntities(
    BuildContext context, {
    required ViewerEntities media,
  }) async {
    if (media.isEmpty) {
      return false;
    }

    if (media.length == 1) {
      return DialogService.deleteEntity(
        context,
        entity: media.entities[0] as StoreEntity,
      );
    } else {
      final String msg;

      msg = 'Are you sure you want to delete ${media.length} items?';
      return template(
        context,
        title: 'Confirm Delete',
        message: msg,
        entity: media,
      );
    }
  }

  static Future<bool?> permanentlyDeleteMedia(
    BuildContext context, {
    required StoreEntity media,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to PERMANENTLY delete '
            'this ${media.mediaType}?',
      );

  static Future<bool?> permanentlyDeleteMediaMultiple(
    BuildContext context, {
    required ViewerEntities media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return DialogService.permanentlyDeleteMedia(
        context,
        media: media.entities[0] as StoreEntity,
      );
    } else {
      msg =
          'Are you sure you want to PERMANENTLY delete  ${media.length} items?';
    }

    return template(
      context,
      title: 'Confirm Delete',
      message: msg,
    );
  }

  static Future<bool?> restoreMedia(
    BuildContext context, {
    required StoreEntity media,
  }) async =>
      template(
        context,
        title: 'Confirm Restore',
        message: 'Are you sure you want to restore '
            'this ${media.type}?',
      );

  static Future<bool?> restoreMediaMultiple(
    BuildContext context, {
    required ViewerEntities media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    if (media.length == 1) {
      return DialogService.restoreMedia(
        context,
        media: media.entities[0] as StoreEntity,
      );
    }
    return template(
      context,
      title: 'Confirm Restore',
      message: 'Are you sure you want to restore  ${media.length} items?',
    );
  }

  static Future<bool?> replaceMedia(
    BuildContext context, {
    required StoreEntity media,
  }) async =>
      template(
        context,
        title: 'Confirm Replace',
        message: 'This will replace the original file with the above media',
      );
  static Future<bool?> cloneAndReplaceMedia(
    BuildContext context, {
    required StoreEntity media,
  }) async =>
      template(
        context,
        title: 'Save',
        message: 'This will save the above media as a separate copy, '
            'other propertes will be copied from original media',
      );
  static Future<bool?> deleteNote(
    BuildContext context, {
    required StoreEntity note,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            "this note? You can't recover it",
      );
}
