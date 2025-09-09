import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class NetworkScanner {
  const NetworkScanner({required this.lanStatus, required this.servers});

  factory NetworkScanner.unknown() {
    return const NetworkScanner(lanStatus: false, servers: <CLUrl>{});
  }
  final bool lanStatus;
  final Set<CLUrl> servers;

  NetworkScanner copyWith({bool? lanStatus, Set<CLUrl>? servers}) {
    return NetworkScanner(
      lanStatus: lanStatus ?? this.lanStatus,
      servers: servers ?? this.servers,
    );
  }

  @override
  bool operator ==(covariant NetworkScanner other) {
    if (identical(this, other)) return true;
    final setEquals = const DeepCollectionEquality().equals;

    return other.lanStatus == lanStatus && setEquals(other.servers, servers);
  }

  @override
  int get hashCode => lanStatus.hashCode ^ servers.hashCode;

  @override
  String toString() =>
      'NetworkScanner(lanStatus: $lanStatus, servers: $servers)';

  bool get isEmpty => servers.isEmpty;
  bool get isNotEmpty => servers.isNotEmpty;

  NetworkScanner clearServers() {
    return NetworkScanner(lanStatus: lanStatus, servers: const {});
  }

  void search() {}
}
