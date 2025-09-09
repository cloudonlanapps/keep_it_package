import 'dart:async';

import 'package:cl_servers/cl_servers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e_preferred_server.dart';

final activeAIServerProvider =
    AsyncNotifierProvider<ActiveAIServerNotifier, CLServer?>(
      ActiveAIServerNotifier.new,
    );

class ActiveAIServerNotifier extends AsyncNotifier<CLServer?> {
  @override
  FutureOr<CLServer?> build() async {
    final servers = await ref.watch(availableServersProvider('ai.').future);

    final userPreferredServerUri = ref.watch(preferredServerIdProvider);

    final server = servers
        .where((server) => server.storeURL.uri == userPreferredServerUri)
        .firstOrNull;

    return server;
  }
}
