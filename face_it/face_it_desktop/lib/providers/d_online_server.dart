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

extension DownloadExt on CLServer {
  Future<String?> downloadFile(String url, String targetFile) async {
    final response = await get(url, outputFileName: targetFile);

    return response.when(
      validResponse: (result) async {
        return result as String;
      },
      errorResponse: (e, {st}) async {
        print(e);
        return null;
      },
    );
  }
}
