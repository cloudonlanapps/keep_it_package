import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class ServerPreferences {
  const ServerPreferences({this.uri, this.autoConnect = true});

  factory ServerPreferences.fromMap(Map<String, dynamic> map) {
    return ServerPreferences(
      uri: map['preferredUri'] == null
          ? null
          : Uri.parse(map['preferredUri'] as String),
      autoConnect: map['autoConnect'] as bool,
    );
  }

  factory ServerPreferences.fromJson(String source) =>
      ServerPreferences.fromMap(json.decode(source) as Map<String, dynamic>);
  final Uri? uri;
  final bool autoConnect;

  ServerPreferences copyWith({ValueGetter<Uri?>? uri, bool? autoConnect}) {
    return ServerPreferences(
      uri: uri != null ? uri.call() : this.uri,
      autoConnect: autoConnect ?? this.autoConnect,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'preferredUri': uri?.toString(),
      'autoConnect': autoConnect,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ServerPreferences(preferredUri: $uri, autoConnect: $autoConnect)';

  @override
  bool operator ==(covariant ServerPreferences other) {
    if (identical(this, other)) return true;

    return other.uri == uri && other.autoConnect == autoConnect;
  }

  @override
  int get hashCode => uri.hashCode ^ autoConnect.hashCode;
}
