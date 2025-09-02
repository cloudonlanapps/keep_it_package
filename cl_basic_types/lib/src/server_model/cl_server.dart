import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class CLServer {
  const CLServer({required this.storeURL, this.connected = false});

  final CLUrl storeURL;

  final bool connected;
  //  final ServerTimeStamps? status;

  CLServer copyWith({CLUrl? storeURL, bool? connected}) {
    return CLServer(
      storeURL: storeURL ?? this.storeURL,
      connected: connected ?? this.connected,
    );
  }

  @override
  String toString() {
    return 'CLServer(url: $storeURL,  connected: $connected)';
  }

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.storeURL == storeURL && other.connected == connected;
  }

  @override
  int get hashCode {
    return storeURL.hashCode ^ connected.hashCode;
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

  Future<CLServer> withId({http.Client? client}) async {
    try {
      final reply = await RestApi(baseURL, client: client).getURLStatus();
      return switch (reply) {
        (final StoreResult<Map<String, dynamic>> _) => copyWith(
          connected: true,
        ),
        _ => copyWith(connected: false),
      };
    } catch (e) {
      return copyWith(connected: false);
    }
  }

  Future<CLServer> getServerLiveStatus({http.Client? client}) async =>
      withId(client: client);

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
}
