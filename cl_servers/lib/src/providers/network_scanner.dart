import 'dart:async';
import 'dart:typed_data';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';

import '../models/network_scanner.dart';

extension ServiceExtDiscovery on Discovery {
  Future<void> stop() async => stopDiscovery(this);
}

class NetworkScannerNotifier extends StateNotifier<NetworkScanner>
    with CLLogger {
  NetworkScannerNotifier({required this.serviceName})
    : super(NetworkScanner.unknown()) {
    log('Instance created ');
    unawaited(_initialize());
  }
  @override
  String get logPrefix => 'NetworkScannerNotifier';

  final String serviceName;

  Discovery? discovery;
  StreamSubscription<List<ConnectivityResult>>? subscription;

  bool isUpdating = false;

  Future<void> _initialize() async {
    subscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      final updatedLanStatus =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      if (updatedLanStatus != state.lanStatus) {
        log(
          'Network Connectivity: '
          '${updatedLanStatus ? "available" : 'not available'} ',
        );

        if (updatedLanStatus) {
          state = state.copyWith(lanStatus: updatedLanStatus);
          unawaited(searchForServers());
        } else {
          state = state.copyWith(lanStatus: updatedLanStatus, servers: {});
        }
      }
    });
    if (subscription != null) {
      log('Network Connectivity: subscribed');
    }
  }

  Future<void> search() async {
    if (state.lanStatus) {
      log('Rescan Request:  ');
      await searchForServers();
    } else {
      log(
        'Rescan Request:  ignored, as the device not connected to any network',
      );
    }
  }

  @override
  void dispose() {
    if (subscription != null) {
      log('Network Connectivity: unsubscribed');
      unawaited(subscription!.cancel().then((_) => subscription = null));
    }
    if (discovery != null) {
      discovery!.removeListener(listener);
      log('NSD: unsusbscribed');
      log(
        'NSD: Stop searching for '
        '"Cloud on LAN" services in the local area network',
      );
      unawaited(discovery!.stop());
    }
    super.dispose();
  }

  Future<void> listener() async {
    final servers = <CLUrl>{};
    for (final e in discovery?.services ?? <Service>[]) {
      final identity = String.fromCharCodes(
        Uint8List.fromList(e.txt?['identifier'] ?? []),
      );

      if (identity.endsWith('cloudonlanapps')) {
        servers.add(
          CLUrl(
            Uri.parse('http://${e.host}:${e.port}'),
            identity: identity,
            label: e.name,
          ),
        );
      }
    }

    if (servers.isNotEmpty) {
      if (state.servers.isDifferent(servers)) {
        log('NSD: Found ${servers.length} server(s) in the network. ');
        state = state.copyWith(servers: servers);
      }
    } else {
      log('NSD: No server in the network. ');
      state = state.copyWith(servers: {});
    }
  }

  Future<void> searchForServers() async {
    log(
      'NSD: Start searching for "Cloud on LAN" '
      'services in the local area network',
    );
    if (discovery != null) {
      discovery!.removeListener(listener);
      await discovery!.stop();
      discovery = null;
    }
    discovery = await startDiscovery(serviceName);

    if (discovery != null) {
      discovery!.addListener(listener);
    }

    return;
  }
}

final networkScannerProvider =
    StateNotifierProvider<NetworkScannerNotifier, NetworkScanner>((ref) {
      final notifier = NetworkScannerNotifier(serviceName: '_colan._tcp');
      ref.onDispose(notifier.dispose);

      return notifier;
    });
