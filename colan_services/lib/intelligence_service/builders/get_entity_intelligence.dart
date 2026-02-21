import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/entity_intelligence_provider.dart';

/// Builder widget that fetches and provides entity intelligence data.
///
/// This builder watches the [entityIntelligenceProvider] and exposes
/// [EntityIntelligenceData] through a callback, handling loading and
/// error states.
///
/// **Auto-refresh behavior:**
/// The underlying provider automatically polls for updates every 5 seconds
/// while intelligence status is 'queued' or 'processing'. Polling stops
/// when status becomes 'completed' or 'failed'.
///
/// Example usage:
/// ```dart
/// GetEntityIntelligence(
///   entityId: 123,
///   config: serverConfig,
///   builder: (intelligence) {
///     if (intelligence == null) {
///       return Text('No intelligence data');
///     }
///     return Column(
///       children: [
///         Text('Status: ${intelligence.overallStatus}'),
///         Text('Faces: ${intelligence.faceCount ?? 0}'),
///       ],
///     );
///   },
///   loadingBuilder: () => CLLoadingView.local(),
///   errorBuilder: (e, st) => CLErrorView.local(message: e.toString()),
/// )
/// ```
class GetEntityIntelligence extends ConsumerWidget with CLLogger {
  const GetEntityIntelligence({
    required this.entityId,
    required this.config,
    required this.builder,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });

  /// The entity ID to fetch intelligence for.
  final int entityId;

  /// The server configuration.
  final RemoteServiceLocationConfig config;

  /// Builder called when intelligence data is available.
  /// Data may be null if no intelligence exists for this entity.
  final Widget Function(EntityIntelligenceData? data) builder;

  /// Builder called while loading.
  final CLLoadingView Function() loadingBuilder;

  /// Builder called on error.
  final CLErrorView Function(Object error, StackTrace stackTrace) errorBuilder;

  @override
  String get logPrefix => 'GetEntityIntelligence';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (entityId: entityId, config: config);
    final dataAsync = ref.watch(entityIntelligenceProvider(key));

    log('Building for entity $entityId, state: ${dataAsync.runtimeType}');

    return dataAsync.when(
      data: (data) {
        log(
          'Data received: status=${data?.overallStatus}, '
          'faceDetection=${data?.inferenceStatus.faceDetection}, '
          'faceCount=${data?.faceCount}',
        );
        return builder(data);
      },
      loading: () {
        log('Loading...');
        return loadingBuilder();
      },
      error: (error, stackTrace) {
        log('Error: $error', error: error, stackTrace: stackTrace);
        return errorBuilder(error, stackTrace);
      },
    );
  }
}

/// Extension methods for convenient status checks on [EntityIntelligenceData].
extension EntityIntelligenceDataX on EntityIntelligenceData? {
  /// Returns true if face detection is completed.
  bool get isFaceDetectionCompleted =>
      this?.inferenceStatus.faceDetection == 'completed';

  /// Returns true if face detection is in progress.
  bool get isFaceDetectionInProgress =>
      this?.inferenceStatus.faceDetection == 'in_progress';

  /// Returns true if face detection is queued.
  bool get isFaceDetectionQueued =>
      this?.inferenceStatus.faceDetection == 'queued';

  /// Returns true if face detection failed.
  bool get isFaceDetectionFailed =>
      this?.inferenceStatus.faceDetection == 'failed';

  /// Returns true if face detection is pending.
  bool get isFaceDetectionPending =>
      this?.inferenceStatus.faceDetection == 'pending';

  /// Returns true if any processing is in progress.
  bool get isProcessing => this?.overallStatus == 'processing';

  /// Returns true if all processing is completed.
  bool get isCompleted => this?.overallStatus == 'completed';

  /// Returns true if processing failed.
  bool get isFailed => this?.overallStatus == 'failed';
}
