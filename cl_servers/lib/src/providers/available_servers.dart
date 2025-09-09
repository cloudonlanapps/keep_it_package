import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_server.dart';
import 'network_scanner.dart';
import 'server_provider.dart';

final availableServersProvider =
    AsyncNotifierProviderFamily<
      AvailableServersNotifier,
      List<CLServer>,
      String
    >(AvailableServersNotifier.new);

class AvailableServersNotifier
    extends FamilyAsyncNotifier<List<CLServer>, String> {
  @override
  FutureOr<List<CLServer>> build(String arg) async {
    final scanner = ref.watch(networkScannerProvider);

    final detectedServers = scanner.servers
        .where((e) => e.isType(arg))
        .map(
          (url) => ref
              .watch(serverProvider(url))
              .whenOrNull(data: (clServer) => clServer),
        )
        .cast<CLServer>()
        .toList();
    final servers = detectedServers
        .map((detectedServer) {
          final server = ref.watch(serverProvider(detectedServer.storeURL));

          return server.whenOrNull(data: (data) => data);
        })
        .where((e) => e != null)
        .cast<CLServer>()
        .toList();

    return servers;
  }
}
