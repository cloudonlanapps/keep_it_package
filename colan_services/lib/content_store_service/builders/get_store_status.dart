import 'package:colan_services/server_service/server_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/active_store_provider.dart';
import '../providers/registerred_urls.dart';

class GetStoreStatus extends ConsumerWidget {
  const GetStoreStatus({
    required this.builder,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });

  final Widget Function({
    required ServiceLocationConfig activeConfig,
    required bool isConnected,
    required CLStore store,
  })
  builder;

  final CLLoadingView Function() loadingBuilder;
  final CLErrorView Function(Object e, StackTrace st) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    final locationsAsync = ref.watch(registeredServiceLocationsProvider);

    return locationsAsync.when(
      data: (locations) {
        if (!scanner.lanStatus) {
          return loadingBuilder();
        } else {
          final storeAsync = ref.watch(activeStoreProvider);
          return storeAsync.when(
            data: (store) => builder(
              isConnected: scanner.lanStatus,
              activeConfig: locations.activeConfig,
              store: store,
            ),
            error: errorBuilder,
            loading: loadingBuilder,
          );
        }
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
