import 'package:cl_server_services/cl_server_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetNetworkScanner extends ConsumerWidget {
  const GetNetworkScanner({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(NetworkScanner store) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    return builder(scanner);
  }
}
