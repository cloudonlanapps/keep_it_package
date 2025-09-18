import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/foundation.dart' hide ValueGetter;
import 'package:http/http.dart' as http;

import 'rest_api.dart';

@immutable
class CLServer {
  const CLServer({required this.storeURL, this.connected = false, this.client});

  final CLUrl storeURL;
  final bool connected;
  final http.Client? client;

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

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: Registered Server',
    ); */
  }

  bool validatePingResponse(String responseBody) {
    // final info = jsonDecode(responseBody) as Map<String, dynamic>;
    //FIXME validatePingResponse
    return true;
  }

  Future<CLServer> isConnected({http.Client? client}) async {
    CLServer updated;
    try {
      final reply = await get('');

      updated = switch (reply) {
        (final StoreResult<String> response) => copyWith(
          connected: validatePingResponse(response.result),
        ),
        _ => copyWith(connected: false),
      };
    } catch (e) {
      updated = copyWith(connected: false);
    }

    return updated;
  }

  Uri getEndpointURI(String endPoint) {
    return Uri.parse('$baseURL$endPoint');
  }

  String get baseURL => '${storeURL.uri}';
  static int defaultTimeoutInSec = 3600;
  static http.Client defaultHttpClient = http.Client();
}
