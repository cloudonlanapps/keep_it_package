import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../server_service/providers/server_provider.dart';

/// Key for identifying intelligence requests per entity and server.
typedef IntelligenceKey = ({int entityId, RemoteServiceLocationConfig config});

/// Notifier that fetches and caches intelligence data for a specific entity.
///
/// This provider fetches [EntityIntelligenceData] which includes:
/// - Overall processing status (queued, processing, completed, failed)
/// - Face detection status and count
/// - Embedding statuses (CLIP, DINO)
/// - Active jobs and job history
///
/// **Auto-refresh behavior:**
/// When intelligence status is 'queued' or 'processing', the provider
/// subscribes to MQTT for real-time status updates. When a status change
/// is received via MQTT, the provider refetches data via REST API.
/// This is more efficient than polling.
class EntityIntelligenceNotifier
    extends FamilyAsyncNotifier<EntityIntelligenceData?, IntelligenceKey>
    with CLLogger {
  String? _mqttSubscriptionId;
  StoreManager? _storeManager;

  @override
  String get logPrefix => 'EntityIntelligenceNotifier';

  @override
  FutureOr<EntityIntelligenceData?> build(IntelligenceKey arg) async {
    final entityId = arg.entityId;
    final config = arg.config;

    log('=== BUILD START for entity $entityId ===');

    // Cancel any existing MQTT subscription
    _cancelMqttSubscription();

    // Register cleanup when provider is disposed
    ref.onDispose(() {
      log('Provider disposed for entity $entityId');
      _cancelMqttSubscription();
    });

    log('Step 1: Getting server connection for ${config.label}');

    try {
      final server = await ref.watch(serverProvider(config).future);
      final storeManager = server.storeManager;
      _storeManager = storeManager;

      if (storeManager == null) {
        log('ERROR: StoreManager not available (not authenticated?)');
        return null;
      }

      log('Step 2: Fetching intelligence via REST API');
      final result = await storeManager.getEntityIntelligence(entityId);

      log(
        'REST response: '
        'success=${result.isSuccess}, '
        'statusCode=${result.statusCode}',
      );

      if (result.isSuccess) {
        final data = result.data;
        log(
          'Step 3: Intelligence data received:\n'
          '  - overallStatus: ${data?.overallStatus}\n'
          '  - faceDetection: ${data?.inferenceStatus.faceDetection}\n'
          '  - faceCount: ${data?.faceCount}\n'
          '  - clipEmbedding: ${data?.inferenceStatus.clipEmbedding}\n'
          '  - dinoEmbedding: ${data?.inferenceStatus.dinoEmbedding}',
        );

        // Subscribe to MQTT if still processing
        log('Step 4: Checking if MQTT subscription is needed');
        await _subscribeIfNeeded(data, storeManager, entityId);

        log('=== BUILD COMPLETE for entity $entityId ===');
        return data;
      }

      // Handle 404 gracefully - entity may not have intelligence yet
      if (result.statusCode == 404) {
        log('Step 3: No intelligence data found (404)');
        // Subscribe to MQTT - intelligence may be created later
        log('Step 4: Subscribing to MQTT to wait for intelligence creation');
        await _subscribeIfNeeded(null, storeManager, entityId);
        log('=== BUILD COMPLETE (null) for entity $entityId ===');
        return null;
      }

      log('ERROR: Failed to fetch intelligence: ${result.error}');
      throw Exception(result.error ?? 'Failed to fetch intelligence');
    } catch (e) {
      log('EXCEPTION in build for entity $entityId: $e', error: e);
      rethrow;
    }
  }

  /// Subscribe to MQTT if intelligence is still being processed.
  Future<void> _subscribeIfNeeded(
    EntityIntelligenceData? data,
    StoreManager storeManager,
    int entityId,
  ) async {
    final status = data?.overallStatus;
    final faceStatus = data?.inferenceStatus.faceDetection;

    log(
      'MQTT check: overallStatus=$status, faceDetection=$faceStatus',
    );

    // Don't subscribe if completed or failed
    if (status == 'completed' || status == 'failed') {
      log(
        'MQTT: No subscription needed - '
        'processing finished with status=$status',
      );
      return;
    }

    // Subscribe to MQTT for real-time updates
    log(
      'MQTT: Subscribing to entity $entityId status updates...\n'
      '  Current status: $status\n'
      '  Will wait for: completed or failed',
    );

    try {
      _mqttSubscriptionId = await storeManager.monitorEntity(
        entityId,
        _onMqttStatusUpdate,
      );
      log(
        'MQTT: Subscription SUCCESS\n'
        '  subscriptionId: $_mqttSubscriptionId\n'
        '  entityId: $entityId',
      );
    } catch (e) {
      log(
        'MQTT: Subscription FAILED - $e\n'
        '  Provider will work without real-time updates',
        error: e,
      );
      // Gracefully fail - provider will still work without real-time updates
    }
  }

  /// Handle MQTT status update.
  void _onMqttStatusUpdate(EntityStatusPayload payload) {
    log(
      '=== MQTT MESSAGE RECEIVED ===\n'
      '  entityId: ${payload.entityId}\n'
      '  status: ${payload.status}\n'
      '  faceDetection: ${payload.faceDetection}\n'
      '  faceCount: ${payload.faceCount}\n'
      '  clipEmbedding: ${payload.clipEmbedding}\n'
      '  dinoEmbedding: ${payload.dinoEmbedding}\n'
      '  timestamp: ${payload.timestamp}',
    );

    // Cancel subscription if processing is complete
    if (payload.status == 'completed' || payload.status == 'failed') {
      log(
        'MQTT: Processing complete (status=${payload.status}), '
        'unsubscribing...',
      );
      _cancelMqttSubscription();
    }

    // Invalidate to refetch via REST API
    log('MQTT: Triggering provider refresh to fetch latest data via REST');
    ref.invalidateSelf();
  }

  /// Cancel any existing MQTT subscription.
  void _cancelMqttSubscription() {
    if (_mqttSubscriptionId != null) {
      log(
        'MQTT: Cancelling subscription $_mqttSubscriptionId',
      );
      if (_storeManager != null) {
        _storeManager!.stopMonitoring(_mqttSubscriptionId!);
        log('MQTT: Subscription cancelled successfully');
      } else {
        log('MQTT: WARNING - storeManager is null, cannot unsubscribe');
      }
      _mqttSubscriptionId = null;
    } else {
      log('MQTT: No active subscription to cancel');
    }
  }

  /// Manually refresh the intelligence data for this entity.
  Future<void> refresh() async {
    log('Manual refresh requested');
    ref.invalidateSelf();
  }
}

/// Provider for fetching entity intelligence data.
///
/// Usage:
/// ```dart
/// final key = (entityId: 123, config: serverConfig);
/// final intelligenceAsync = ref.watch(entityIntelligenceProvider(key));
/// ```
final entityIntelligenceProvider = AsyncNotifierProviderFamily<
    EntityIntelligenceNotifier,
    EntityIntelligenceData?,
    IntelligenceKey>(EntityIntelligenceNotifier.new);
