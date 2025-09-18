import 'dart:async';

import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeAIServerProvider =
    AsyncNotifierProviderFamily<
      ActiveAIServerNotifier,
      CLServer?,
      ServerPreferences
    >(ActiveAIServerNotifier.new);

class ActiveAIServerNotifier
    extends FamilyAsyncNotifier<CLServer?, ServerPreferences> {
  @override
  FutureOr<CLServer?> build(ServerPreferences arg) async {
    final servers = await ref.watch(availableServersProvider('ai.').future);
    final server = servers
        .where((server) => server.storeURL.uri == arg.uri)
        .firstOrNull;

    return server;
  }
}
