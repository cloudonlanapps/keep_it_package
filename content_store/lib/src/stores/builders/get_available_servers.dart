import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:content_store/src/stores/providers/registerred_urls.dart';
import 'package:content_store/src/stores/providers/server_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetAvailableServers extends ConsumerWidget {
  const GetAvailableServers({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(List<CLServer>) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerredURLsAsync = ref.watch(registeredURLsProvider);

    return registerredURLsAsync.when(
      data: (urls) {
        final serverURLs = urls.availableStores
            .where((e) => ['https', 'http'].contains(e.scheme));
        try {
          final servers = serverURLs
              .map((storeURL) {
                final server = ref.watch(serverProvider(storeURL));

                return server.whenOrNull(data: (data) => data);
              })
              .where((e) => e != null)
              .cast<CLServer>()
              .toList();

          return builder(servers);
        } catch (e, st) {
          return errorBuilder(e, st);
        }
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
