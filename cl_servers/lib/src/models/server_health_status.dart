import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Runtime health status for a remote server.
///
/// Combines broadcast health information (from the server itself via NSD)
/// with our own health check results.
@immutable
class ServerHealthStatus {
  const ServerHealthStatus({
    required this.lastChecked,
    required this.ourHealthCheckPassed,
    this.broadcastStatus,
    this.broadcastErrors,
  });

  /// Status broadcasted by the server via NSD (e.g., 'healthy', 'unhealthy')
  final String? broadcastStatus;

  /// Errors broadcasted by the server via NSD
  final List<String>? broadcastErrors;

  /// When we last checked the server health
  final DateTime lastChecked;

  /// Whether our own health check passed (ping endpoints)
  final bool ourHealthCheckPassed;

  /// Whether the server reports itself as having issues
  bool get hasBroadcastIssues =>
      broadcastStatus == 'unhealthy' || (broadcastErrors?.isNotEmpty ?? false);

  /// Overall health status - healthy if both broadcast and our check pass
  bool get isHealthy => !hasBroadcastIssues && ourHealthCheckPassed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerHealthStatus &&
          broadcastStatus == other.broadcastStatus &&
          const DeepCollectionEquality().equals(
            broadcastErrors,
            other.broadcastErrors,
          ) &&
          lastChecked == other.lastChecked &&
          ourHealthCheckPassed == other.ourHealthCheckPassed;

  @override
  int get hashCode =>
      broadcastStatus.hashCode ^
      broadcastErrors.hashCode ^
      lastChecked.hashCode ^
      ourHealthCheckPassed.hashCode;

  @override
  String toString() =>
      'ServerHealthStatus(broadcastStatus: $broadcastStatus, '
      'broadcastErrors: $broadcastErrors, lastChecked: $lastChecked, '
      'ourHealthCheckPassed: $ourHealthCheckPassed)';
}
