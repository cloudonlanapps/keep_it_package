import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/entity_faces_provider.dart';

/// Builder widget that fetches and provides face detection results.
///
/// This builder watches the [entityFacesProvider] which internally watches
/// the intelligence status and automatically updates when face detection
/// completes.
///
/// **Auto-refresh behavior:**
/// The underlying provider watches intelligence status and:
/// - Returns empty list while face detection is not completed
/// - Automatically refetches when face detection becomes 'completed'
/// - Polls intelligence every 5 seconds while processing
///
/// Example usage:
/// ```dart
/// GetEntityFaces(
///   entityId: 123,
///   config: serverConfig,
///   builder: (faces) {
///     if (faces.isEmpty) {
///       return const SizedBox.shrink();
///     }
///     return Text('Found ${faces.length} faces');
///   },
///   loadingBuilder: () => const CLLoadingView.hidden(),
///   errorBuilder: (e, st) => const CLErrorView.hidden(),
/// )
/// ```
class GetEntityFaces extends ConsumerWidget with CLLogger {
  const GetEntityFaces({
    required this.entityId,
    required this.config,
    required this.builder,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });

  /// The entity ID to fetch faces for.
  final int entityId;

  /// The server configuration.
  final RemoteServiceLocationConfig config;

  /// Builder called when face data is available.
  /// Returns empty list if face detection is not yet completed.
  final Widget Function(List<FaceResponse> faces) builder;

  /// Builder called while loading.
  final CLLoadingView Function() loadingBuilder;

  /// Builder called on error.
  final CLErrorView Function(Object error, StackTrace stackTrace) errorBuilder;

  @override
  String get logPrefix => 'GetEntityFaces';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (entityId: entityId, config: config);
    final facesAsync = ref.watch(entityFacesProvider(key));

    log('Building for entity $entityId, state: ${facesAsync.runtimeType}');

    return facesAsync.when(
      data: (faces) {
        log('Data received: ${faces.length} faces');
        return builder(faces);
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
