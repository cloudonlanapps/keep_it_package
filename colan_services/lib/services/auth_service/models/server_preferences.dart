import 'dart:convert';
import 'dart:io';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Server configuration preferences for authentication and related services.
@immutable
class ServerPreferences {
  const ServerPreferences({
    required this.authUrl,
    required this.computeUrl,
    required this.storeUrl,
    required this.mqttUrl,
  });

  /// Default server configuration.
  /// Attempts to load from ~/.cl_client_config.json, falls back to localhost.
  factory ServerPreferences.defaults() {
    try {
      final homeDir = Platform.environment['HOME'] ??
                      Platform.environment['USERPROFILE'];
      if (homeDir == null) {
        return ServerPreferences._localhostDefaults();
      }

      final configPath = p.join(homeDir, '.cl_client_config.json');
      final configFile = File(configPath);

      if (!configFile.existsSync()) {
        return ServerPreferences._localhostDefaults();
      }

      final configJson = jsonDecode(configFile.readAsStringSync())
          as Map<String, dynamic>;
      final serverPref = configJson['server_pref'] as Map<String, dynamic>;

      return ServerPreferences(
        authUrl: serverPref['auth_url'] as String,
        computeUrl: serverPref['compute_url'] as String,
        storeUrl: serverPref['store_url'] as String,
        mqttUrl: serverPref['mqtt_url'] as String,
      );
    } catch (e) {
      // If loading fails, use localhost defaults
      return ServerPreferences._localhostDefaults();
    }
  }

  /// Localhost defaults when config file is not available.
  factory ServerPreferences._localhostDefaults() {
    return const ServerPreferences(
      authUrl: 'http://localhost:8010',
      computeUrl: 'http://localhost:8012',
      storeUrl: 'http://localhost:8011',
      mqttUrl: 'mqtt://localhost:1883',
    );
  }

  /// Auth service URL.
  final String authUrl;

  /// Compute service URL.
  final String computeUrl;

  /// Store service URL.
  final String storeUrl;

  /// MQTT broker URL.
  final String mqttUrl;

  /// Converts to ServerConfig for dartsdk SessionManager.
  ServerConfig toServerConfig() => ServerConfig(
        authUrl: authUrl,
        computeUrl: computeUrl,
        storeUrl: storeUrl,
        mqttUrl: mqttUrl,
      );

  /// Creates a copy with updated fields.
  ServerPreferences copyWith({
    String? authUrl,
    String? computeUrl,
    String? storeUrl,
    String? mqttUrl,
  }) {
    return ServerPreferences(
      authUrl: authUrl ?? this.authUrl,
      computeUrl: computeUrl ?? this.computeUrl,
      storeUrl: storeUrl ?? this.storeUrl,
      mqttUrl: mqttUrl ?? this.mqttUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerPreferences &&
          runtimeType == other.runtimeType &&
          authUrl == other.authUrl &&
          computeUrl == other.computeUrl &&
          storeUrl == other.storeUrl &&
          mqttUrl == other.mqttUrl;

  @override
  int get hashCode =>
      authUrl.hashCode ^
      computeUrl.hashCode ^
      storeUrl.hashCode ^
      mqttUrl.hashCode;

  @override
  String toString() {
    return 'ServerPreferences(authUrl: $authUrl, computeUrl: $computeUrl, '
        'storeUrl: $storeUrl, mqttUrl: $mqttUrl)';
  }
}
