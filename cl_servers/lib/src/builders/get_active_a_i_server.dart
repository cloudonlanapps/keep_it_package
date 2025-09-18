import 'package:cl_servers/cl_servers.dart' show CLServer;
import 'package:cl_servers/src/providers/active_ai_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/server_preferences.dart';

class GetActiveAIServer extends ConsumerWidget {
  const GetActiveAIServer({
    required this.serverURI,
    required this.builder,
    super.key,
  });
  final ServerPreferences serverURI;
  final Widget Function(CLServer? activeAIServer) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAIServer = ref
        .watch(activeAIServerProvider(serverURI))
        .whenOrNull(data: (data) => data);
    return builder(activeAIServer);
  }
}
