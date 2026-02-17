import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/available_servers.dart';

class GetAvailableServers extends ConsumerWidget {
  const GetAvailableServers({
    required this.serverType,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final String serverType;

  final Widget Function(List<CLServer>) builder;
  final CLErrorView Function(Object, StackTrace) errorBuilder;
  final CLLoadingView Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(availableServersProvider(serverType))
        .when(data: builder, error: errorBuilder, loading: loadingBuilder);
  }
}
