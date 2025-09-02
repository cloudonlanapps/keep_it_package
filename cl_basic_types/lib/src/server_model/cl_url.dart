import 'dart:convert';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

@immutable
class CLUrl implements Comparable<CLUrl> {
  const CLUrl(this.uri, {required this.identity, required this.label});

  factory CLUrl.fromMap(Map<String, dynamic> map) {
    return CLUrl(
      Uri.parse(map['uri'] as String),
      identity: map['identity'] != null ? map['identity'] as String : null,
      label: map['label'] != null ? map['label'] as String : null,
    );
  }

  factory CLUrl.fromJson(String source) =>
      CLUrl.fromMap(json.decode(source) as Map<String, dynamic>);

  factory CLUrl.fromString(
    String url, {
    required String? identity,
    required String? label,
  }) {
    return CLUrl(Uri.parse(url), identity: identity, label: label);
  }
  final Uri uri;
  final String? identity;
  final String? label;
  String get scheme => uri.scheme;
  String get name =>
      identity?.capitalizeFirstLetter() ??
      (uri.host.isNotEmpty ? uri.host : uri.path);

  @override
  bool operator ==(covariant CLUrl other) {
    if (identical(this, other)) return true;

    return other.uri == uri && other.identity == identity;
  }

  @override
  int get hashCode => uri.hashCode ^ identity.hashCode;

  @override
  String toString() => 'CLUrl(uri: $uri, identity: $identity, label: $label)';

  CLUrl copyWith({
    Uri? uri,
    ValueGetter<String?>? identity,
    ValueGetter<String?>? label,
  }) {
    return CLUrl(
      uri ?? this.uri,
      identity: identity != null ? identity.call() : this.identity,
      label: label != null ? label.call() : this.label,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uri': '$uri',
      'identity': identity,
      'label': label,
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
}
