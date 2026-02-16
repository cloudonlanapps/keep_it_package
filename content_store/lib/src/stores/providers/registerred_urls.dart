import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_services/cl_server_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';

import '../models/registered_service_locations.dart';
import 'store_provider.dart';

class RegisteredServiceLocationsNotifier
    extends AsyncNotifier<RegisteredServiceLocations>
    with CLLogger {
  @override
  String get logPrefix => 'RegisteredServiceLocationsNotifier';

  final defaultStore = const LocalServiceLocationConfig(
    storePath: 'default',
    identity: 'default',
    label: 'Primary Collection',
  );

  @override
  FutureOr<RegisteredServiceLocations> build() {
    try {
      final scanner = ref.watch(networkScannerProvider);
      final configs = <ServiceLocationConfig>[
        defaultStore,
        const LocalServiceLocationConfig(
          storePath: 'QuotesCollection',
          identity: 'Quote Collection',
          label: 'Quote Collection',
        ),

        // Add remote servers from network scanner
        if (scanner.lanStatus)
          ...scanner.remoteConfigs.where((e) => e.isRepoServer),
      ];

      final registered = RegisteredServiceLocations(
        availableConfigs: configs,
        activeIndex: 0,
      );

      ref.listen(storeProvider(registered.activeConfig), (prev, next) {
        next.whenData((store) {
          if (!store.entityStore.isAlive) {
            // assuming 0 is always available
            activeConfig = registered.availableConfigs[0];
          }
        });
      });

      return registered;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  ServiceLocationConfig get activeConfig => state.value!.activeConfig;
  set activeConfig(ServiceLocationConfig config) =>
      state = AsyncValue.data(state.value!.setActiveConfig(config));
}

final registeredServiceLocationsProvider =
    AsyncNotifierProvider<
      RegisteredServiceLocationsNotifier,
      RegisteredServiceLocations
    >(RegisteredServiceLocationsNotifier.new);
