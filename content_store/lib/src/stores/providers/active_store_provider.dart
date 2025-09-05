import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart' show CLLogger;
import 'package:content_store/src/stores/providers/registerred_urls.dart';
import 'package:content_store/src/stores/providers/store_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class ActiveStoreNotifier extends AsyncNotifier<CLStore> with CLLogger {
  @override
  String get logPrefix => 'ActiveStoreNotifier';
  @override
  FutureOr<CLStore> build() async {
    try {
      final registerredURLs = await ref.watch(registeredURLsProvider.future);
      final storeURL = registerredURLs.activeStoreURL;

      final activeStore = ref.watch(storeProvider(storeURL).future);
      return activeStore;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final activeStoreProvider = AsyncNotifierProvider<ActiveStoreNotifier, CLStore>(
    ActiveStoreNotifier.new);
