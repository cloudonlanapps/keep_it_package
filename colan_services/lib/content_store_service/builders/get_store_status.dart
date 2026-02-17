import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_services/server_service/server_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/active_store_provider.dart';
import '../providers/registerred_urls.dart';

class GetStoreStatus extends ConsumerWidget {
  const GetStoreStatus({
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    super.key,
  });

  final Widget Function({
    required ServiceLocationConfig activeConfig,
    required bool isConnected,
    required CLStore store,
  })
  builder;

  final Widget Function()? loadingBuilder;
  final Widget Function(Object e, StackTrace st)? errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    final locationsAsync = ref.watch(registeredServiceLocationsProvider);

    return locationsAsync.when(
      data: (locations) {
        if (!scanner.lanStatus) {
          if (loadingBuilder != null) return loadingBuilder!();
          return const Center(child: CircularProgressIndicator());
        } else {
          final storeAsync = ref.watch(activeStoreProvider);
          return storeAsync.when(
            data: (store) => builder(
              isConnected: scanner.lanStatus,
              activeConfig: locations.activeConfig,
              store: store,
            ),
            error: (e, st) {
              if (errorBuilder != null) return errorBuilder!(e, st);
              return Center(child: Text(e.toString()));
            },
            loading: () {
              if (loadingBuilder != null) return loadingBuilder!();
              return const Center(child: CircularProgressIndicator());
            },
          );
        }
      },
      error: (e, st) {
        if (errorBuilder != null) return errorBuilder!(e, st);
        return Center(child: Text(e.toString()));
      },
      loading: () {
        if (loadingBuilder != null) return loadingBuilder!();
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
