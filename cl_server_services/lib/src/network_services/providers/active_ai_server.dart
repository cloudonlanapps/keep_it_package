import 'dart:async';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        .where((server) => server.locationConfig.uri == uri)
        .firstOrNull;

    return server;
  }
}
