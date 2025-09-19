import 'package:cl_servers/cl_servers.dart' show CLServer;
import 'package:cl_servers/src/providers/active_ai_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetActiveAIServer extends ConsumerWidget {
  const GetActiveAIServer({required this.builder, super.key});

  final Widget Function(CLServer? activeAIServer) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAIServer = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (data) => data);
    return builder(activeAIServer);
  }
}
