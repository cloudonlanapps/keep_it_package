import 'package:cl_servers/src/models/cl_socket.dart';
import 'package:cl_servers/src/providers/socket_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/server_preferences.dart';

class GetServerSession extends ConsumerWidget {
  const GetServerSession({
    required this.serverUri,
    required this.builder,
    super.key,
  });
  final ServerPreferences serverUri;
  final Widget Function(CLSocket? socket) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIO = ref
        .watch(socketConnectionProvider(serverUri))
        .whenOrNull(data: (io) => io);
    return builder(serverIO);
  }
}
