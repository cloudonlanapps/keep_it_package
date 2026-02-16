import 'package:cl_server_dart_client/cl_server_dart_client.dart' as sdk;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'cl_logger.dart';
import 'remote_service_location_config.dart';
import 'server_health_status.dart';
import 'value_getter.dart';

@immutable
class CLServer with CLLogger {
  const CLServer({
    required this.locationConfig,
    required this.healthStatus,
    this.client,
    this.sessionManager,
    this.currentUser,
    this.loginTimestamp,
    this.storeManager,
  });

  final RemoteServiceLocationConfig locationConfig;
  final ServerHealthStatus healthStatus;
  final http.Client? client;

  // Auth state (merged from AuthState)
  final sdk.SessionManager? sessionManager;
  final sdk.UserResponse? currentUser;
  final DateTime? loginTimestamp;

  // Store operations (automatically created when logged in)
  final sdk.StoreManager? storeManager;

  bool get connected => healthStatus.isHealthy;
  bool get isAuthenticated => sessionManager?.isAuthenticated ?? false;

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
    ValueGetter<sdk.SessionManager?>? sessionManager,
    ValueGetter<sdk.UserResponse?>? currentUser,
    ValueGetter<DateTime?>? loginTimestamp,
    ValueGetter<sdk.StoreManager?>? storeManager,
  }) {
    return CLServer(
      locationConfig: locationConfig ?? this.locationConfig,
      healthStatus: healthStatus ?? this.healthStatus,
      client: client != null ? client.call() : this.client,
      sessionManager: sessionManager != null
          ? sessionManager.call()
          : this.sessionManager,
      currentUser: currentUser != null ? currentUser.call() : this.currentUser,
      loginTimestamp: loginTimestamp != null
          ? loginTimestamp.call()
          : this.loginTimestamp,
      storeManager: storeManager != null
          ? storeManager.call()
          : this.storeManager,
    );
  }

  @override
  String toString() {
    return 'CLServer(locationConfig: $locationConfig, healthStatus: $healthStatus, client: $client, isAuthenticated: $isAuthenticated, currentUser: $currentUser)';
  }

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.locationConfig == locationConfig &&
        other.healthStatus == healthStatus &&
        other.client == client &&
        other.sessionManager == sessionManager &&
        other.currentUser == currentUser &&
        other.loginTimestamp == loginTimestamp &&
        other.storeManager == storeManager;
  }

  @override
  int get hashCode {
    return locationConfig.hashCode ^
        healthStatus.hashCode ^
        client.hashCode ^
        sessionManager.hashCode ^
        currentUser.hashCode ^
        loginTimestamp.hashCode ^
        storeManager.hashCode;
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
