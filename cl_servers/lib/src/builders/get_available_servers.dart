import 'package:cl_basic_types/cl_basic_types.dart';
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
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(availableServersProvider(serverType))
        .when(data: builder, error: errorBuilder, loading: loadingBuilder);
  }
}
