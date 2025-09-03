// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

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
    final info = jsonDecode(responseBody) as Map<String, dynamic>;
    if ((info['name'] as String) == 'CoLAN server') {
      return true;
    }
    return false;
  }

  Future<CLServer> isConnected({http.Client? client}) async {
    try {
      final reply = get("");
      return switch (reply) {
        (final StoreResult<String> response) => copyWith(
          connected: validatePingResponse(response.result),
        ),
        _ => copyWith(connected: false),
      };
    } catch (e) {
      return copyWith(connected: false);
    }
  }

  String get identifier {
    const separator = '_';
    if (!connected) return 'Unknown';
    final id = storeURL.identity.toInt();

    var hexString = id!.toRadixString(16).toUpperCase();
    hexString = hexString.padLeft(4, '0');
    final formattedHex = hexString.replaceAllMapped(
      RegExp('.{4}'),
      (match) => '${match.group(0)}$separator',
    );
    final identifierString = formattedHex.endsWith(separator)
        ? formattedHex.substring(0, formattedHex.length - 1)
        : formattedHex;
    return identifierString;
  }

  Uri getEndpointURI(String endPoint) {
    return Uri.parse('$baseURL$endPoint');
  }

  String get baseURL => '${storeURL.uri}';
  static int defaultTimeoutInSec = 3600;
  static http.Client defaultHttpClient = http.Client();
}
