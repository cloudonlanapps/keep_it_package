import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

/// Abstract base class for service location configurations.
///
/// A service location represents WHERE services are available (local or remote).
/// This is separate from the actual store implementation (WHAT stores data).
@immutable
abstract class ServiceLocationConfig {
  const ServiceLocationConfig({
    this.identity,
    this.label,
  });

  /// Optional identity for the service location (e.g., 'repo.identifier.cloudonlanapps')
  final String? identity;

  /// Optional user-friendly label for the service location
  final String? label;

  /// Whether this service location is local (filesystem) or remote (server)
  bool get isLocal;

  /// Display name computed from identity or label
  String get displayName =>
      identity?.capitalizeFirstLetter() ?? label ?? 'Unknown';

  /// Serialize to map for storage/transmission
  Map<String, dynamic> toMap();
}
