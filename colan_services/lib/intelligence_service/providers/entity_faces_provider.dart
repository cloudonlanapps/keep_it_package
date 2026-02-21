import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../server_service/providers/server_provider.dart';
import 'entity_intelligence_provider.dart';

/// Key for identifying face requests per entity and server.
typedef FacesKey = ({int entityId, RemoteServiceLocationConfig config});

/// Notifier that fetches and caches face detection results for a specific entity.
///
/// This provider fetches [List<FaceResponse>] which includes:
/// - Face bounding boxes (normalized 0.0-1.0 coordinates)
/// - Facial landmarks (eyes, nose, mouth)
/// - Detection confidence scores
/// - Known person IDs (if face recognition has been performed)
///
/// **Auto-refresh behavior:**
/// This provider watches [entityIntelligenceProvider] and automatically
/// refetches face data when face detection status changes to 'completed'.
class EntityFacesNotifier
    extends FamilyAsyncNotifier<List<FaceResponse>, FacesKey>
    with CLLogger {
  String? _lastFaceDetectionStatus;

  @override
  String get logPrefix => 'EntityFacesNotifier';

  @override
  FutureOr<List<FaceResponse>> build(FacesKey arg) async {
    final entityId = arg.entityId;
    final config = arg.config;

    log('=== FACES BUILD START for entity $entityId ===');

    // Watch intelligence provider to react to status changes
    log('Step 1: Watching intelligence provider for status updates');
    final intelligenceKey = (entityId: entityId, config: config);
    final intelligenceAsync =
        ref.watch(entityIntelligenceProvider(intelligenceKey));

    // Get face detection status from intelligence
    final intelligence = intelligenceAsync.valueOrNull;
    final faceDetectionStatus = intelligence?.inferenceStatus.faceDetection;
    final overallStatus = intelligence?.overallStatus;

    log(
      'Step 2: Intelligence state check:\n'
      '  intelligenceAsync.isLoading: ${intelligenceAsync.isLoading}\n'
      '  intelligenceAsync.hasValue: ${intelligenceAsync.hasValue}\n'
      '  intelligenceAsync.hasError: ${intelligenceAsync.hasError}\n'
      '  overallStatus: $overallStatus\n'
      '  faceDetectionStatus: $faceDetectionStatus\n'
      '  previousFaceDetectionStatus: $_lastFaceDetectionStatus',
    );

    // Track status changes
    final statusChanged = _lastFaceDetectionStatus != faceDetectionStatus;
    _lastFaceDetectionStatus = faceDetectionStatus;

    if (statusChanged) {
      log(
        'IMPORTANT: Face detection status CHANGED: '
        '$_lastFaceDetectionStatus -> $faceDetectionStatus',
      );
    }

    // If face detection is not completed, return empty list
    if (faceDetectionStatus != 'completed') {
      log(
        'Step 3: Face detection not completed (status=$faceDetectionStatus)\n'
        '  Returning empty list. '
        'Provider will rebuild when intelligence updates.',
      );
      log('=== FACES BUILD COMPLETE (empty) for entity $entityId ===');
      return [];
    }

    log(
      'Step 3: Face detection is COMPLETED, fetching faces via REST\n'
      '  Server: ${config.label}',
    );

    try {
      final server = await ref.watch(serverProvider(config).future);
      final storeManager = server.storeManager;

      if (storeManager == null) {
        log('ERROR: StoreManager not available (not authenticated?)');
        return [];
      }

      log('Step 4: Calling storeManager.getEntityFaces($entityId)');
      final result = await storeManager.getEntityFaces(entityId);

      log(
        'REST response: success=${result.isSuccess}, '
        'statusCode=${result.statusCode}',
      );

      if (result.isSuccess) {
        final faces = result.data ?? [];
        log(
          'Step 5: Successfully retrieved ${faces.length} faces '
          'for entity $entityId',
        );

        // VERIFY: Check that all returned faces belong to this entity
        for (var i = 0; i < faces.length; i++) {
          final face = faces[i];
          if (face.entityId != entityId) {
            log(
              'ERROR: Face ${face.id} has entityId=${face.entityId} '
              'but we requested entityId=$entityId! SERVER DATA MISMATCH!',
            );
          }
          log(
            '  Face[$i] id=${face.id}, entityId=${face.entityId}:\n'
            '    confidence: ${face.confidence.toStringAsFixed(3)}\n'
            '    bbox: (${face.bbox.x1.toStringAsFixed(3)}, '
            '${face.bbox.y1.toStringAsFixed(3)}) -> '
            '(${face.bbox.x2.toStringAsFixed(3)}, '
            '${face.bbox.y2.toStringAsFixed(3)})\n'
            '    knownPersonId: ${face.knownPersonId ?? "unknown"}',
          );
        }
        log('=== FACES BUILD COMPLETE (${faces.length} faces) '
            'for entity $entityId ===');
        return faces;
      }

      // Handle 404 gracefully - entity may not have faces
      if (result.statusCode == 404) {
        log('Step 5: No faces found for entity $entityId (404 response)');
        log('=== FACES BUILD COMPLETE (empty) for entity $entityId ===');
        return [];
      }

      log('ERROR: Failed to fetch faces: ${result.error}');
      throw Exception(result.error ?? 'Failed to fetch faces');
    } catch (e) {
      log('EXCEPTION in faces build for entity $entityId: $e', error: e);
      rethrow;
    }
  }

  /// Manually refresh the face data for this entity.
  Future<void> refresh() async {
    log('Manual refresh requested');
    ref.invalidateSelf();
  }
}

/// Provider for fetching entity face detection results.
///
/// Usage:
/// ```dart
/// final key = (entityId: 123, config: serverConfig);
/// final facesAsync = ref.watch(entityFacesProvider(key));
/// ```
final entityFacesProvider = AsyncNotifierProviderFamily<
    EntityFacesNotifier,
    List<FaceResponse>,
    FacesKey>(EntityFacesNotifier.new);
