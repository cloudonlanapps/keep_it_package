import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/server_service/server_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:store/store.dart';

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

      // When the list of available stores changes (e.g. after a network scan),
      // try to preserve the currently active store selection.
      final previousState = state.valueOrNull;
      var activeIndex = 0; // Default to Primary Collection

      if (previousState != null) {
        final currentActiveIdentity = previousState.activeConfig.identity;
        final foundIndex = configs.indexWhere(
          (c) => c.identity == currentActiveIdentity,
        );

        if (foundIndex != -1) {
          activeIndex = foundIndex;
        } else {
          log(
            'Active store ${previousState.activeConfig.label} is no longer available. Reverting to default.',
          );
        }
      }

      final registered = RegisteredServiceLocations(
        availableConfigs: configs,
        activeIndex: activeIndex,
      );

      // Listen to active store health
      ref.listen(storeProvider(registered.activeConfig), (prev, next) {
        next.whenData((store) {
          if (!store.entityStore.isAlive) {
            log(
              'Active store ${registered.activeConfig.label} is no longer alive, switching to default',
            );
            activeConfig = configs[0];
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
  set activeConfig(ServiceLocationConfig config) {
    if (config is RemoteServiceLocationConfig) {
      log('Switching to remote server ${config.label}, invalidating providers');
      ref
        ..invalidate(serverHealthCheckProvider(config))
        ..invalidate(storeProvider(config));
    }
    state = AsyncValue.data(state.value!.setActiveConfig(config));
  }
}

final registeredServiceLocationsProvider =
    AsyncNotifierProvider<
      RegisteredServiceLocationsNotifier,
      RegisteredServiceLocations
    >(RegisteredServiceLocationsNotifier.new);
