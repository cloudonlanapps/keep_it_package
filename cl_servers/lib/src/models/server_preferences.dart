import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class ServerPreferences {
  const ServerPreferences({
    this.uri,
    this.autoConnect = true,
    this.autoUpload = true,
    this.autoFaceRecg = true,
  });

  factory ServerPreferences.fromMap(Map<String, dynamic> map) {
    return ServerPreferences(
      uri: map['uri'] != null ? Uri.parse(map['preferredUri'] as String) : null,
      autoConnect: map['autoConnect'] as bool,
      autoUpload: map['autoUpload'] as bool,
      autoFaceRecg: map['autoFaceRecg'] as bool,
    );
  }

  factory ServerPreferences.fromJson(String source) =>
      ServerPreferences.fromMap(json.decode(source) as Map<String, dynamic>);
  final Uri? uri;
  final bool autoConnect;
  final bool autoUpload;
  final bool autoFaceRecg;

  ServerPreferences copyWith({
    ValueGetter<Uri?>? uri,
    bool? autoConnect,
    bool? autoUpload,
    bool? autoFaceRecg,
  }) {
    return ServerPreferences(
      uri: uri != null ? uri.call() : this.uri,
      autoConnect: autoConnect ?? this.autoConnect,
      autoUpload: autoUpload ?? this.autoUpload,
      autoFaceRecg: autoFaceRecg ?? this.autoFaceRecg,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uri': uri?.toString(),
      'autoConnect': autoConnect,
      'autoUpload': autoUpload,
      'autoFaceRecg': autoFaceRecg,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ServerPreferences(uri: $uri, autoConnect: $autoConnect, autoUpload: $autoUpload, autoFaceRecg: $autoFaceRecg)';
  }

  @override
  bool operator ==(covariant ServerPreferences other) {
    if (identical(this, other)) return true;

    return other.uri == uri &&
        other.autoConnect == autoConnect &&
        other.autoUpload == autoUpload &&
        other.autoFaceRecg == autoFaceRecg;
  }

  @override
  int get hashCode {
    return uri.hashCode ^
        autoConnect.hashCode ^
        autoUpload.hashCode ^
        autoFaceRecg.hashCode;
  }
}
