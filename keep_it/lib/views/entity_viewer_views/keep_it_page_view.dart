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
          faceOverlayBuilder: config != null
              ? (entity) => _FaceOverlayBuilder(
                    entity: entity,
                    config: config!,
                  )
              : null,
        ),
      ),
    );
  }
}

/// Internal widget that builds face overlay for an entity.
class _FaceOverlayBuilder extends ConsumerWidget {
  const _FaceOverlayBuilder({
    required this.entity,
    required this.config,
  });

  final ViewerEntity entity;
  final RemoteServiceLocationConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityId = entity.id;
    if (entityId == null) {
      return const SizedBox.shrink();
    }

    return GetFaceOverlaySettings(
      // Key ensures settings widget rebuilds when entity changes
      key: ValueKey('face_settings_$entityId'),
      builder: (settings, _) {
        // Don't render if overlay is disabled
        if (!settings.isEnabled) {
          return const SizedBox.shrink();
        }

        return GetEntityFaces(
          // Key ensures widget rebuilds when entity changes
          key: ValueKey('get_faces_$entityId'),
          entityId: entityId,
          config: config,
          builder: (faces) {
            if (faces.isEmpty) {
              return const SizedBox.shrink();
            }

            // VERIFY: Check that all returned faces belong to this entity
            for (final face in faces) {
              if (face.entityId != entityId) {
                dev.log(
                  'WARNING: Face ${face.id} has entityId=${face.entityId} '
                  'but we requested entityId=$entityId! Data mismatch!',
                  name: 'FaceOverlay',
                );
              }
            }

            dev.log(
              'Building face overlay for entity $entityId: '
              '${faces.length} faces, '
              'faceIds=${faces.map((f) => f.id).join(", ")}',
              name: 'FaceOverlay',
            );

            // Convert FaceResponse to FaceData using factory constructor
            final faceDataList =
                faces.map(FaceData.fromFaceResponse).toList();

            // Get image dimensions from entity
            final imageWidth = entity.width ?? 1920;
            final imageHeight = entity.height ?? 1080;

            return FacesOverlayLayer(
              // Use ValueKey to ensure widget rebuilds when entity changes
              key: ValueKey('face_overlay_$entityId'),
              entityId: entityId,
              faces: faceDataList,
              imageWidth: imageWidth,
              imageHeight: imageHeight,
              showBoxes: settings.showBoxes,
              showLandmarks: settings.showLandmarks,
              onFaceTapped: (face) => _onFaceTapped(face, ref),
            );
          },
          loadingBuilder: () =>
              const CLLoadingView.hidden(debugMessage: 'Loading faces'),
          errorBuilder: (error, stackTrace) =>
              const CLErrorView.hidden(debugMessage: 'Failed to load faces'),
        );
      },
    );
  }

  /// Handle face tap - log face info and toggle menu.
  void _onFaceTapped(FaceData face, WidgetRef ref) {
    dev.log(
      'Face tapped: '
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
