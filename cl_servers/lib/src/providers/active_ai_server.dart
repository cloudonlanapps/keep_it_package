import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_server.dart';
import 'available_servers.dart';
import 'server_preference.dart';

final activeAIServerProvider =
    AsyncNotifierProvider<ActiveAIServerNotifier, CLServer?>(
      ActiveAIServerNotifier.new,
    );

class ActiveAIServerNotifier extends AsyncNotifier<CLServer?> {
  @override
  FutureOr<CLServer?> build() async {
    final uri = ref.watch(serverPreferenceProvider.select((e) => e.uri));
    if (uri == null) return null;
    final servers = await ref.watch(availableServersProvider('ai.').future);
    final server = servers
        .where((server) => server.storeURL.uri == uri)
        .firstOrNull;

    return server;
  }
}
