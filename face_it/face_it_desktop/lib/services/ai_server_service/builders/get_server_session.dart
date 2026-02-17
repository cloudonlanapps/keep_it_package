import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/socket_connection.dart';

class GetServerSession extends ConsumerWidget {
  const GetServerSession({required this.builder, super.key});

  final Widget Function(CLSocket? socket) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverIO = ref
        .watch(socketConnectionProvider)
        .whenOrNull(data: (io) => io);
    return builder(serverIO);
  }
}
