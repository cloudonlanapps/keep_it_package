import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

/// Configuration for a local service location.
///
/// Represents services running on the local filesystem (not a remote server).
@immutable
class LocalServiceLocationConfig extends ServiceLocationConfig {
  const LocalServiceLocationConfig({
    required this.storePath,
    super.identity,
    super.label,
  });

  /// Create from map (deserialization)
  factory LocalServiceLocationConfig.fromMap(Map<String, dynamic> map) {
    return LocalServiceLocationConfig(
      storePath: map['storePath'] as String,
      identity: map['identity'] as String?,
      label: map['label'] as String?,
    );
  }

  /// Path identifier for the local store (e.g., "default", "QuotesCollection")
  final String storePath;

  @override
  bool get isLocal => true;

  /// Scheme is always 'local' for local service locations
  String get scheme => 'local';

  /// URI representation using local:// scheme
  Uri get uri => Uri(scheme: 'local', host: storePath);

  @override
  Map<String, dynamic> toMap() {
    return {
      'storePath': storePath,
      'identity': identity,
      'label': label,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalServiceLocationConfig &&
          storePath == other.storePath &&
          identity == other.identity &&
          label == other.label;

  @override
  int get hashCode => storePath.hashCode ^ identity.hashCode ^ label.hashCode;

  @override
  String toString() =>
      'LocalServiceLocationConfig(storePath: $storePath, identity: $identity, label: $label)';
}
