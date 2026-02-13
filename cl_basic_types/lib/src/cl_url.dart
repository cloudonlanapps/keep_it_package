import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
class CLUrl implements Comparable<CLUrl> {
  const CLUrl(
    this.config, {
    required this.identity,
    required this.label,
    this.broadcastStatus,
    this.broadcastErrors,
  });

  factory CLUrl.fromMap(Map<String, dynamic> map) {
    return CLUrl(
      ServerConfig(
        authUrl: map['authUrl'] as String,
        storeUrl: map['storeUrl'] as String,
        computeUrl: map['computeUrl'] as String,
        mqttUrl: map['mqttUrl'] as String,
      ),
      identity: map['identity'] != null ? map['identity'] as String : null,
      label: map['label'] != null ? map['label'] as String : null,
      broadcastStatus: map['broadcastStatus'] != null
          ? map['broadcastStatus'] as String
          : null,
      broadcastErrors: map['broadcastErrors'] != null
          ? List<String>.from(map['broadcastErrors'] as List)
          : null,
    );
  }

  factory CLUrl.fromJson(String source) =>
      CLUrl.fromMap(json.decode(source) as Map<String, dynamic>);

  factory CLUrl.fromString(
    String url, {
    required String? identity,
    required String? label,
  }) {
    // For backward compatibility - create ServerConfig with same URL for all services
    return CLUrl(
      ServerConfig(
        authUrl: url,
        storeUrl: url,
        computeUrl: url,
        mqttUrl: 'mqtt://localhost:1883', // Default MQTT URL
      ),
      identity: identity,
      label: label,
    );
  }

  final ServerConfig config;
  final String? identity;
  final String? label;
  final String? broadcastStatus;
  final List<String>? broadcastErrors;

  // Computed property: server reports itself as unhealthy
  bool get hasBroadcastIssues =>
      broadcastStatus == 'unhealthy' ||
      (broadcastErrors != null && broadcastErrors!.isNotEmpty);

  // Convenience getters for service URLs
  String get authUrl => config.authUrl;
  String get storeUrl => config.storeUrl;
  String get computeUrl => config.computeUrl;
  String get mqttUrl => config.mqttUrl;

  // Backward compatibility - return store URL as Uri
  Uri get uri => Uri.parse(config.storeUrl);
  String get scheme => Uri.parse(config.storeUrl).scheme;

  String get name =>
      identity?.capitalizeFirstLetter() ??
      (uri.host.isNotEmpty ? uri.host : uri.path);

  @override
  bool operator ==(covariant CLUrl other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.config == config &&
        other.identity == identity &&
        other.broadcastStatus == broadcastStatus &&
        listEquals(other.broadcastErrors, broadcastErrors);
  }

  @override
  int get hashCode {
    return config.hashCode ^
        identity.hashCode ^
        broadcastStatus.hashCode ^
        broadcastErrors.hashCode;
  }

  @override
  String toString() =>
      'CLUrl(config: $config, identity: $identity, label: $label, '
      'broadcastStatus: $broadcastStatus, broadcastErrors: $broadcastErrors)';

  CLUrl copyWith({
    ServerConfig? config,
    ValueGetter<String?>? identity,
    ValueGetter<String?>? label,
    ValueGetter<String?>? broadcastStatus,
    ValueGetter<List<String>?>? broadcastErrors,
  }) {
    return CLUrl(
      config ?? this.config,
      identity: identity != null ? identity.call() : this.identity,
      label: label != null ? label.call() : this.label,
      broadcastStatus: broadcastStatus != null
          ? broadcastStatus.call()
          : this.broadcastStatus,
      broadcastErrors: broadcastErrors != null
          ? broadcastErrors.call()
          : this.broadcastErrors,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'authUrl': config.authUrl,
      'storeUrl': config.storeUrl,
      'computeUrl': config.computeUrl,
      'mqttUrl': config.mqttUrl,
      'identity': identity,
      'label': label,
      'broadcastStatus': broadcastStatus,
      'broadcastErrors': broadcastErrors,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  int compareTo(CLUrl other) {
    if (identity == null && other.identity == null) {
      return 0; // They are considered equal for comparison purposes.
    }
    // Case 2: My value is null, but the other's isn't.
    // Conventionally, null is treated as smaller.
    if (identity == null) {
      return -1;
    }
    // Case 3: My value isn't null, but the other's is.
    // My value is larger.
    if (other.identity == null) {
      return 1;
    }
    return identity!.compareTo(other.identity!);
  }

  bool isType(String type) => identity != null && identity!.startsWith(type);

  bool get isRepoServer => isType('repo.');
}
