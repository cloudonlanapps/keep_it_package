import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/registerred_urls.dart';
import '../providers/store_provider.dart';

class GetAvailableStores extends ConsumerWidget {
  const GetAvailableStores({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(List<CLStore>) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registeredLocationsAsync = ref.watch(
      registeredServiceLocationsProvider,
    );

    return registeredLocationsAsync.when(
      data: (locations) {
        try {
          final stores = locations.availableConfigs
              .map((config) {
                final store = ref.watch(storeProvider(config));
                return store.whenOrNull(data: (data) => data);
              })
              .where((e) => e != null)
              .cast<CLStore>()
              .toList();
          if (stores.isEmpty) {
            throw Exception("stores can't be empty");
          }
          return builder(stores);
        } catch (e, st) {
          return errorBuilder(e, st);
        }
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
