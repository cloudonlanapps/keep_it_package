import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:content_store/src/stores/providers/active_store_provider.dart';
import 'package:content_store/src/stores/providers/network_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/registerred_urls.dart';

class GetStoreStatus extends ConsumerWidget {
  const GetStoreStatus({required this.builder, super.key});

  final Widget Function(
      {required AsyncValue<CLUrl> activeURL,
      required bool isConnected,
      required AsyncValue<CLStore> storeAsync}) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    final registerredURLsAsync = ref.watch(registeredURLsProvider);

    return registerredURLsAsync.when(data: (registerredURLs) {
      if (!scanner.lanStatus) {
        return builder(
            isConnected: scanner.lanStatus,
            activeURL: AsyncData(registerredURLs.activeStoreURL),
            storeAsync: const AsyncLoading());
      } else {
        final storeAsync = ref.watch(activeStoreProvider);
        return builder(
            isConnected: scanner.lanStatus,
            activeURL: AsyncData(registerredURLs.activeStoreURL),
            storeAsync: storeAsync);
      }
    }, error: (e, st) {
      return builder(
          isConnected: scanner.lanStatus,
          activeURL: AsyncError(e, st),
          storeAsync: const AsyncLoading());
    }, loading: () {
      return builder(
          isConnected: scanner.lanStatus,
          activeURL: const AsyncLoading(),
          storeAsync: const AsyncLoading());
    });
  }
}
