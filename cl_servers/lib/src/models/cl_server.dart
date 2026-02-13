import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:http/http.dart' as http;

@immutable
class CLServer with CLLogger {
  const CLServer({required this.storeURL, this.connected = false, this.client});

  final CLUrl storeURL;
  final bool connected;
  final http.Client? client;

  // Convenience getters for service URLs
  String get authUrl => storeURL.authUrl;
  String get computeUrl => storeURL.computeUrl;
  String get mqttUrl => storeURL.mqttUrl;

  // Expose broadcast health status
  String? get broadcastStatus => storeURL.broadcastStatus;
  List<String>? get broadcastErrors => storeURL.broadcastErrors;
  bool get hasBroadcastIssues => storeURL.hasBroadcastIssues;

  CLServer copyWith({
    CLUrl? storeURL,
    bool? connected,
    ValueGetter<http.Client?>? client,
  }) {
    return CLServer(
      storeURL: storeURL ?? this.storeURL,
      connected: connected ?? this.connected,
      client: client != null ? client.call() : this.client,
    );
  }

  @override
  String toString() {
    return 'CLServer(storeURL: $storeURL, connected: $connected, client: $client)';
  }

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.storeURL == storeURL &&
        other.connected == connected &&
        other.client == client;
  }

  @override
  int get hashCode {
    return storeURL.hashCode ^ connected.hashCode ^ client.hashCode;
  }

  Uri getEndpointURI(String endPoint) {
    return Uri.parse('$baseURL$endPoint');
  }

  String get baseURL => '${storeURL.uri}';
  static int defaultTimeoutInSec = 3600;
  static http.Client defaultHttpClient = http.Client();

  @override
  String get logPrefix => 'CLServer';
}
