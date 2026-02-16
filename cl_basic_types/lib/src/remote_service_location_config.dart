import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:meta/meta.dart';

import 'service_location_config.dart';

/// Configuration for a remote service location.
///
/// Represents services running on a remote server with multiple service endpoints
/// (auth, store, compute, mqtt).
@immutable
class RemoteServiceLocationConfig extends ServiceLocationConfig {
  const RemoteServiceLocationConfig({
    required this.serverConfig,
    required super.identity,
    super.label,
  });

  /// Create from ServerConfig
  factory RemoteServiceLocationConfig.fromServerConfig(
    ServerConfig config, {
    required String identity,
    String? label,
  }) {
    return RemoteServiceLocationConfig(
      serverConfig: config,
      identity: identity,
      label: label,
    );
  }

  /// Create from map (deserialization)
  factory RemoteServiceLocationConfig.fromMap(Map<String, dynamic> map) {
    return RemoteServiceLocationConfig(
      serverConfig: ServerConfig(
        authUrl: map['authUrl'] as String,
        storeUrl: map['storeUrl'] as String,
        computeUrl: map['computeUrl'] as String,
        mqttUrl: map['mqttUrl'] as String,
      ),
      identity: map['identity'] as String,
      label: map['label'] as String?,
    );
  }

  /// Server configuration containing all service URLs
  /// (authUrl, storeUrl, computeUrl, mqttUrl)
  final ServerConfig serverConfig;

  @override
  bool get isLocal => false;

  /// Scheme extracted from store URL (http or https)
  String get scheme => Uri.parse(serverConfig.storeUrl).scheme;

  /// Primary URI from store URL
  Uri get uri => Uri.parse(serverConfig.storeUrl);

  // Convenience getters for service URLs
  String get authUrl => serverConfig.authUrl;
  String get storeUrl => serverConfig.storeUrl;
  String get computeUrl => serverConfig.computeUrl;
  String get mqttUrl => serverConfig.mqttUrl;

  @override
  Map<String, dynamic> toMap() {
    return {
      'authUrl': serverConfig.authUrl,
      'storeUrl': serverConfig.storeUrl,
      'computeUrl': serverConfig.computeUrl,
      'mqttUrl': serverConfig.mqttUrl,
      'identity': identity,
      'label': label,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteServiceLocationConfig &&
          serverConfig == other.serverConfig &&
          identity == other.identity &&
          label == other.label;

  @override
  int get hashCode =>
      serverConfig.hashCode ^ identity.hashCode ^ label.hashCode;

  @override
  String toString() =>
      'RemoteServiceLocationConfig(serverConfig: $serverConfig, identity: $identity, label: $label)';

  /// Check if this service location matches a specific type by identity prefix
  bool isType(String type) => identity.startsWith(type);

  /// Check if this is a repository server
  bool get isRepoServer => isType('repo.');
}
