import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../views/common_widgets/fullscreen_layout.dart';
import '../page_manager.dart';

class CameraService extends StatelessWidget {
  const CameraService({
    required this.serverId,
    required this.parentId,
    super.key,
  });
  final String serverId;
  final int? parentId;

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      child: GetDefaultStore(
        errorBuilder: (_, _) {
          throw UnimplementedError('errorBuilder');
        },
        loadingBuilder: () => CLLoader.widget(
          debugMessage: 'GetStoreUpdater',
        ),
        builder: (theStore) {
          return GetStoreTaskManager(
            contentOrigin: ContentOrigin.camera,
            builder: (cameraTaskManager) {
              return GetEntity(
                id: parentId,
                errorBuilder: (_, _) {
                  throw UnimplementedError('errorBuilder');
                },
                loadingBuilder: () => CLLoader.widget(
                  debugMessage: 'GetCollection',
                ),
                builder: (collection) {
                  return CLCameraService0(
                    onCancel: () => PageManager.of(context).pop(),
                    onNewMedia: (path, {required isVideo}) async {
                      final mediaFile = await CLMediaFileUtils.fromPath(path);

                      if (mediaFile != null) {
                        return (await theStore.createMedia(
                          mediaFile: mediaFile,
                          label: () =>
                              p.basenameWithoutExtension(mediaFile.path),
                          description: () => 'captured with Camera',
                        ))?.dbSave(mediaFile.path);
                      }
                      return null;
                    },
                    onDone: (mediaList) async {
                      cameraTaskManager.add(
                        StoreTask(
                          items: mediaList.entities.cast<StoreEntity>(),
                          contentOrigin: ContentOrigin.camera,
                          collection: collection,
                        ),
                      );
                      await PageManager.of(
                        context,
                      ).openWizard(ContentOrigin.camera);

                      if (context.mounted) {
                        PageManager.of(context).pop();
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CLCameraService0 extends StatelessWidget {
  const CLCameraService0({
    required this.onDone,
    required this.onNewMedia,
    this.onCancel,
    super.key,
    this.onError,
  });

  final VoidCallback? onCancel;
  final Future<void> Function(ViewerEntities mediaList) onDone;
  final Future<StoreEntity?> Function(String, {required bool isVideo})
  onNewMedia;

  final void Function(String message, {required dynamic error})? onError;
  static Future<bool> invokeWithSufficientPermission(
    BuildContext context,
    Future<void> Function() callback, {
    required CLCameraThemeData themeData,
  }) async => CLCamera.invokeWithSufficientPermission(
    context,
    callback,
    themeData: themeData,
  );

  @override
  Widget build(BuildContext context) {
    return GetCameras(
      builder: ({required cameras}) {
        return GetCapturedMedia(
          builder: (media, actions) {
            return CLCamera(
              onCancel: () {
                // Confirm ?
                actions.clear();
                onCancel?.call();
              },
              cameras: cameras,
              onCapture: (file, {required isVideo}) async {
                String? updatedFile;
                if (isVideo) {
                  /// Refer https://github.com/flutter/flutter/issues/148335
                  /// android_camerax plugin returns .temp extension
                  /// for recorded video
                  final currentExtension = p.extension(file);
                  if (currentExtension.toLowerCase() != '.mp4') {
                    updatedFile = p.setExtension(file, '.mp4');
                    File(file).copySync(updatedFile);
                    File(file).deleteSync();
                  }
                }
                final media = await onNewMedia(
                  updatedFile ?? file,
                  isVideo: isVideo,
                );
                // Validate if the media has id, has required files here.
                if (media != null) {
                  actions.add(media);
                }
              },
              previewWidget: PreviewCapturedMedia(
                sendMedia: onDone,
              ),
              themeData: DefaultCLCameraIcons(),
              onError: onError,
            );
          },
        );
      },
    );
  }
}
