import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Broadcast health information for a discovered server
@immutable
class BroadcastHealth {
  const BroadcastHealth({
    this.status,
    this.errors,
  });

  final String? status;
  final List<String>? errors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BroadcastHealth &&
          status == other.status &&
          const DeepCollectionEquality().equals(errors, other.errors);

  @override
  int get hashCode => status.hashCode ^ errors.hashCode;
}

@immutable
class NetworkScanner {
  const NetworkScanner({
    required this.lanStatus,
    required this.servers,
    this.broadcastHealthMap = const {},
  });

  factory NetworkScanner.unknown() {
    return const NetworkScanner(
      lanStatus: false,
      servers: <RemoteServiceLocationConfig>{},
    );
  }

  final bool lanStatus;
  final Set<RemoteServiceLocationConfig> servers;

  /// Map of server configs to their broadcast health information
  final Map<RemoteServiceLocationConfig, BroadcastHealth> broadcastHealthMap;

  NetworkScanner copyWith({
    bool? lanStatus,
    Set<RemoteServiceLocationConfig>? servers,
    Map<RemoteServiceLocationConfig, BroadcastHealth>? broadcastHealthMap,
  }) {
    return NetworkScanner(
      lanStatus: lanStatus ?? this.lanStatus,
      servers: servers ?? this.servers,
      broadcastHealthMap: broadcastHealthMap ?? this.broadcastHealthMap,
    );
  }

  /// Get broadcast health for a specific server config
  BroadcastHealth? getBroadcastHealth(RemoteServiceLocationConfig config) {
    return broadcastHealthMap[config];
  }

  /// Convenience getter for remote configs
  List<RemoteServiceLocationConfig> get remoteConfigs => servers.toList();

  @override
  bool operator ==(covariant NetworkScanner other) {
    if (identical(this, other)) return true;
    final deepEquals = const DeepCollectionEquality().equals;

    return other.lanStatus == lanStatus &&
        deepEquals(other.servers, servers) &&
        deepEquals(other.broadcastHealthMap, broadcastHealthMap);
  }

  @override
  int get hashCode =>
      lanStatus.hashCode ^ servers.hashCode ^ broadcastHealthMap.hashCode;

  @override
  String toString() =>
      'NetworkScanner(lanStatus: $lanStatus, servers: $servers, broadcastHealthMap: $broadcastHealthMap)';

  bool get isEmpty => servers.isEmpty;
  bool get isNotEmpty => servers.isNotEmpty;

  NetworkScanner clearServers() {
    return NetworkScanner(
      lanStatus: lanStatus,
      servers: const {},
    );
  }

  void search() {}
}
