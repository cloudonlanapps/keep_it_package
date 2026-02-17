import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'registerred_urls.dart';
import 'store_provider.dart';

class ActiveStoreNotifier extends AsyncNotifier<CLStore> with CLLogger {
  @override
  String get logPrefix => 'ActiveStoreNotifier';

  @override
  FutureOr<CLStore> build() async {
    try {
      final registeredLocations = await ref.watch(
        registeredServiceLocationsProvider.future,
      );
      final config = registeredLocations.activeConfig;

      final activeStore = ref.watch(storeProvider(config).future);
      return activeStore;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final activeStoreProvider = AsyncNotifierProvider<ActiveStoreNotifier, CLStore>(
  ActiveStoreNotifier.new,
);
