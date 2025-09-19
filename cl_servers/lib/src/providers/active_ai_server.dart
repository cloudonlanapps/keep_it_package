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
    final pref = ref.watch(serverPreferenceProvider);
    if (pref.uri == null) return null;
    final servers = await ref.watch(availableServersProvider('ai.').future);
    final server = servers
        .where((server) => server.storeURL.uri == pref.uri)
        .firstOrNull;

    return server;
  }
}
