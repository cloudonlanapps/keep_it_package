import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferred_server.dart';

final onlineServerProvider =
    AsyncNotifierProvider<OnlineServerNotifier, CLServer?>(
      OnlineServerNotifier.new,
    );

class OnlineServerNotifier extends AsyncNotifier<CLServer?> {
  @override
  FutureOr<CLServer?> build() async {
    final urls = await ref.watch(registeredURLsProvider.future);
    final userPreferredServerUri = ref.watch(preferredServerIdProvider);

    final server = urls.availableStores
        .where((e) => ['https', 'http'].contains(e.scheme))
        .map(
          (url) => ref
              .watch(serverProvider(url))
              .whenOrNull(data: (clServer) => clServer),
        )
        .where((e) => e != null)
        .cast<CLServer>()
        .where((server) => server.storeURL.uri == userPreferredServerUri)
        .firstOrNull;

    return server;
  }
}
