import 'package:cl_servers/cl_servers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
