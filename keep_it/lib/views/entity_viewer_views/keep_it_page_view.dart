import 'dart:developer' as dev;

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart'
    show RemoteServiceLocationConfig;
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../page_manager.dart';
import 'bottom_bar_page_view.dart';
import 'top_bar.dart';

class KeepItPageView extends StatelessWidget {
  const KeepItPageView({
    required this.serverId,
    required this.entity,
    required this.siblings,
    this.onLoadMore,
    this.config,
    super.key,
  });

  final StoreEntity entity;
  final ViewerEntities siblings;
  final String serverId;
  final Future<void> Function()? onLoadMore;

  /// Optional remote service config for face detection.
  /// If provided, face overlays will be shown on images.
  final RemoteServiceLocationConfig? config;

  @override
  Widget build(BuildContext context) {
    return OnSwipe(
      onSwipe: () {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      },
      child: CLEntitiesPageViewScope(
        siblings: siblings,
        currentEntity: entity,
        child: CLEntitiesPageView(
          onLoadMore: onLoadMore,
          topMenuBuilder: (currentEntity) => TopBar(
            entity: currentEntity as StoreEntity?,
            children: const ViewerEntities([]),
          ),
          bottomMenu: BottomBarPageView(
            serverId: serverId,
          ),
          imageDataWrapper: config != null
              ? (entity, mediaBuilder) => _ImageDataWrapper(
                    entity: entity,
                    config: config!,
                    mediaBuilder: mediaBuilder,
                  )
              : null,
        ),
      ),
    );
  }
}

/// Internal widget that provides image data with faces for an entity.
///
/// This widget watches the faces provider directly and always shows the media.
/// When faces are loaded, it rebuilds with the face data included.
class _ImageDataWrapper extends ConsumerWidget {
  const _ImageDataWrapper({
    required this.entity,
    required this.config,
    required this.mediaBuilder,
  });

  final ViewerEntity entity;
  final RemoteServiceLocationConfig config;
  final Widget Function(InteractiveImageData imageData) mediaBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityId = entity.id;

    // Build default image data without faces
    final defaultImageData = InteractiveImageData(
      uri: entity.mediaUri!,
      width: (entity.width ?? 1920).toDouble(),
      height: (entity.height ?? 1080).toDouble(),
    );

    // If no entity ID, show without faces
    if (entityId == null) {
      return mediaBuilder(defaultImageData);
    }

    // Check face overlay settings first
    return GetFaceOverlaySettings(
      key: ValueKey('face_settings_$entityId'),
      builder: (settings, _) {
        // If overlay is disabled, show without faces
        if (!settings.isEnabled) {
          return mediaBuilder(defaultImageData);
        }

        // Watch the faces provider directly
        final facesKey = (entityId: entityId, config: config);
        final facesAsync = ref.watch(entityFacesProvider(facesKey));

        return facesAsync.when(
          data: (faces) {
            // Verify faces belong to this entity
            for (final face in faces) {
              if (face.entityId != entityId) {
                dev.log(
                  'WARNING: Face ${face.id} has entityId=${face.entityId} '
                  'but we requested entityId=$entityId! Data mismatch!',
                  name: 'FaceOverlay',
                );
              }
            }

            if (faces.isNotEmpty) {
              dev.log(
                'Building image data for entity $entityId: '
                '${faces.length} faces, '
                'faceIds=${faces.map((f) => f.id).join(", ")}',
                name: 'FaceOverlay',
              );
            }

            // Convert FaceResponse to InteractiveFace
            final interactiveFaces = faces.map((faceResponse) {
              final faceData = FaceData.fromFaceResponse(faceResponse);
              return InteractiveFace(
                data: faceData,
                onTap: settings.showBoxes
                    ? (position) => _onFaceTapped(faceData, position, ref)
                    : null,
              );
            }).toList();

            // Build image data with faces
            final imageData = InteractiveImageData(
              uri: entity.mediaUri!,
              width: (entity.width ?? 1920).toDouble(),
              height: (entity.height ?? 1080).toDouble(),
              faces: interactiveFaces,
            );

            return mediaBuilder(imageData);
          },
          // While loading, show media without faces
          loading: () => mediaBuilder(defaultImageData),
          // On error, show media without faces
          error: (error, stackTrace) {
            dev.log(
              'Failed to load faces for entity $entityId: $error',
              name: 'FaceOverlay',
            );
            return mediaBuilder(defaultImageData);
          },
        );
      },
    );
  }

  /// Handle face tap - log face info and toggle menu.
  void _onFaceTapped(FaceData face, Offset position, WidgetRef ref) {
    dev.log(
      'Face tapped at $position: '
      'id=${face.id}, '
      'confidence=${face.confidence.toStringAsFixed(3)}, '
      'bbox=(${face.bbox.x1.toStringAsFixed(3)}, ${face.bbox.y1.toStringAsFixed(3)}, '
      '${face.bbox.x2.toStringAsFixed(3)}, ${face.bbox.y2.toStringAsFixed(3)}), '
      'knownPersonId=${face.knownPersonId ?? "unknown"}',
      name: 'FaceOverlay',
    );

    // Toggle menu (same behavior as tapping on image)
    ref.read(mediaViewerUIStateProvider.notifier).toggleMenu();
  }
}
