import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:http/http.dart' as http;

import 'remote_service_location_config.dart';
import 'server_health_status.dart';

@immutable
class CLServer with CLLogger {
  const CLServer({
    required this.locationConfig,
    required this.healthStatus,
    this.client,
  });

  final RemoteServiceLocationConfig locationConfig;
  final ServerHealthStatus healthStatus;
  final http.Client? client;

  bool get connected => healthStatus.isHealthy;

  // Convenience getters for service URLs
  String get authUrl => locationConfig.authUrl;
  String get storeUrl => locationConfig.storeUrl;
  String get computeUrl => locationConfig.computeUrl;
  String get mqttUrl => locationConfig.mqttUrl;

  // Expose broadcast health status
  String? get broadcastStatus => healthStatus.broadcastStatus;
  List<String>? get broadcastErrors => healthStatus.broadcastErrors;
  bool get hasBroadcastIssues => healthStatus.hasBroadcastIssues;

  CLServer copyWith({
    RemoteServiceLocationConfig? locationConfig,
    ServerHealthStatus? healthStatus,
    ValueGetter<http.Client?>? client,
  }) {
    return CLServer(
      locationConfig: locationConfig ?? this.locationConfig,
      healthStatus: healthStatus ?? this.healthStatus,
      client: client != null ? client.call() : this.client,
    );
  }

  @override
  String toString() {
    return 'CLServer(locationConfig: $locationConfig, healthStatus: $healthStatus, client: $client)';
  }

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.locationConfig == locationConfig &&
        other.healthStatus == healthStatus &&
        other.client == client;
  }

  @override
  int get hashCode {
    return locationConfig.hashCode ^ healthStatus.hashCode ^ client.hashCode;
  }

  Uri getEndpointURI(String endPoint) {
    return Uri.parse('$baseURL$endPoint');
  }

  String get baseURL => locationConfig.uri.toString();
  static int defaultTimeoutInSec = 3600;
  static http.Client defaultHttpClient = http.Client();

  @override
  String get logPrefix => 'CLServer';
}
