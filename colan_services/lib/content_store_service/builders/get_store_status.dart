import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_services/server_service/server_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/active_store_provider.dart';
import '../providers/registerred_urls.dart';

class GetStoreStatus extends ConsumerWidget {
  const GetStoreStatus({required this.builder, super.key});

  final Widget Function({
    required AsyncValue<ServiceLocationConfig> activeConfig,
    required bool isConnected,
    required AsyncValue<CLStore> storeAsync,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    final locationsAsync = ref.watch(registeredServiceLocationsProvider);

    return locationsAsync.when(
      data: (locations) {
        if (!scanner.lanStatus) {
          return builder(
            isConnected: scanner.lanStatus,
            activeConfig: AsyncData(locations.activeConfig),
            storeAsync: const AsyncLoading(),
          );
        } else {
          final storeAsync = ref.watch(activeStoreProvider);
          return builder(
            isConnected: scanner.lanStatus,
            activeConfig: AsyncData(locations.activeConfig),
            storeAsync: storeAsync,
          );
        }
      },
      error: (e, st) {
        return builder(
          isConnected: scanner.lanStatus,
          activeConfig: AsyncError(e, st),
          storeAsync: const AsyncLoading(),
        );
      },
      loading: () {
        return builder(
          isConnected: scanner.lanStatus,
          activeConfig: const AsyncLoading(),
          storeAsync: const AsyncLoading(),
        );
      },
    );
  }
}
