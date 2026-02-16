import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          (config) => ref
              .watch(serverProvider(config))
              .whenOrNull(data: (clServer) => clServer),
        )
        .where((e) => e != null)
        .cast<CLServer>()
        .toList();
    final servers = detectedServers
        .map((detectedServer) {
          final server = ref.watch(
            serverProvider(detectedServer.locationConfig),
          );

          return server.whenOrNull(data: (data) => data);
        })
        .where((e) => e != null)
        .cast<CLServer>()
        .toList();

    return servers;
  }
}
