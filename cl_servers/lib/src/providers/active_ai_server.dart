import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeAIServerProvider =
    AsyncNotifierProviderFamily<ActiveAIServerNotifier, CLServer?, String?>(
      ActiveAIServerNotifier.new,
    );

class ActiveAIServerNotifier extends FamilyAsyncNotifier<CLServer?, String?> {
  @override
  FutureOr<CLServer?> build(String? arg) async {
    final userPreferredServerUri = arg;
    final servers = await ref.watch(availableServersProvider('ai.').future);
    final server = servers
        .where((server) => server.storeURL.uri == userPreferredServerUri)
        .firstOrNull;

    return server;
  }
}
