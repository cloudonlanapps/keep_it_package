import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeAIServerProvider =
    AsyncNotifierProviderFamily<ActiveAIServerNotifier, CLServer?, Uri?>(
      ActiveAIServerNotifier.new,
    );

class ActiveAIServerNotifier extends FamilyAsyncNotifier<CLServer?, Uri?> {
  @override
  FutureOr<CLServer?> build(Uri? arg) async {
    final userPreferredServerUri = arg;
    final servers = await ref.watch(availableServersProvider('ai.').future);
    final server = servers
        .where((server) => server.storeURL.uri == userPreferredServerUri)
        .firstOrNull;

    return server;
  }
}
