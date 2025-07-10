import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_editors/media_editors.dart';

import '../../internal/fullscreen_layout.dart';
import '../../models/platform_support.dart';
import '../basic_page_service/basic_page_service.dart';
import '../basic_page_service/widgets/dialogs.dart';
import '../basic_page_service/widgets/page_manager.dart';

class MediaEditService extends ConsumerWidget {
  const MediaEditService({
    required this.serverId,
    required this.mediaId,
    required this.canDuplicateMedia,
    super.key,
  });
  final String serverId;
  final int? mediaId;
  final bool canDuplicateMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
      child: (mediaId == null)
          ? BasicPageService.message(message: 'No Media Provided')
          : GetEntity(
              id: mediaId,
              errorBuilder: (_, __) {
                throw UnimplementedError('errorBuilder');
              },
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetMedia',
              ),
              builder: (media) {
                if (media == null) {
                  return BasicPageService.message(message: ' Media not found');
                }

                return GetActiveStore(
                  errorBuilder: (_, __) {
                    throw UnimplementedError('errorBuilder');
                  },
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetStoreUpdater',
                  ),
                  builder: (theStore) {
                    return InvokeEditor(
                      mediaUri: media.mediaUri!,
                      mediaType: media.mediaType,
                      canDuplicateMedia: canDuplicateMedia,
                      onCreateNewFile: () async {
                        return theStore.createTempFile(
                          ext: media.extension!,
                        );
                      },
                      onCancel: () async {
                        PageManager.of(context).pop(media);
                      },
                      onSave: (file, {required overwrite}) async {
                        final mediaFile = await CLMediaFileUtils.fromPath(file);
                        if (mediaFile == null) {
                          throw Exception('failed process $file');
                        }
                        var resultMedia = media;

                        if (overwrite && context.mounted) {
                          final confirmed = await DialogService.replaceMedia(
                                context,
                                serverId: serverId,
                                media: media,
                              ) ??
                              false;
                          if (confirmed && context.mounted) {
                            resultMedia = await media.updateWith(
                                    mediaFile: mediaFile, autoSave: true) ??
                                media;
                          }
                        } else if (context.mounted) {
                          final confirmed =
                              await DialogService.cloneAndReplaceMedia(
                                    context,
                                    serverId: serverId,
                                    media: media,
                                  ) ??
                                  false;
                          if (confirmed && context.mounted) {
                            resultMedia = await media.cloneWith(
                                    mediaFile: mediaFile, autoSave: true) ??
                                media;
                          } else {
                            resultMedia = media;
                          }
                        }

                        if (context.mounted) {
                          if (resultMedia != media) {
                            ref.read(reloadProvider.notifier).reload();
                          }
                          PageManager.of(context).pop(resultMedia);
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class InvokeEditor extends StatelessWidget {
  const InvokeEditor({
    required this.mediaUri,
    required this.mediaType,
    required this.onCreateNewFile,
    required this.onSave,
    required this.onCancel,
    required this.canDuplicateMedia,
    super.key,
  });
  final Uri mediaUri;
  final CLMediaType mediaType;
  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;
  final Future<void> Function() onCancel;
  final bool canDuplicateMedia;
  @override
  Widget build(BuildContext context) {
    switch (mediaType) {
      case CLMediaType.image:
        return ImageEditor(
          uri: mediaUri,
          onCancel: onCancel,
          onSave: onSave,
          onCreateNewFile: onCreateNewFile,
          canDuplicateMedia: canDuplicateMedia,
        );
      case CLMediaType.video:
        if (ColanPlatformSupport.isMobilePlatform) {
          return VideoEditor(
            uri: mediaUri,
            onSave: onSave,
            onCancel: onCancel,
            onCreateNewFile: onCreateNewFile,
            canDuplicateMedia: canDuplicateMedia,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PageManager.of(context).pop();
        });
        return Container();
      case CLMediaType.collection:
      case CLMediaType.text:
      case CLMediaType.uri:
      case CLMediaType.audio:
      case CLMediaType.file:
      case CLMediaType.unknown:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PageManager.of(context).pop();
        });
        return Container();
    }
  }
}
