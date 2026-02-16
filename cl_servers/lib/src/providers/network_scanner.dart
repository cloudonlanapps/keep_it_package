import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
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
    final servers = <RemoteServiceLocationConfig>{};
    final broadcastHealthMap = <RemoteServiceLocationConfig, BroadcastHealth>{};

    // Parse all discovered services (no health checks here)
    for (final service in discovery?.services ?? <Service>[]) {
      final result = _parseService(service);
      if (result != null) {
        servers.add(result.$1);
        if (result.$2 != null) {
          broadcastHealthMap[result.$1] = result.$2!;
        }
      }
    }

    // Update state with all discovered servers and their broadcast health
    if (servers.isNotEmpty) {
      if (state.servers.isDifferent(servers)) {
        log('NSD: Found ${servers.length} server(s) in the network.');
        state = state.copyWith(
          servers: servers,
          broadcastHealthMap: broadcastHealthMap,
        );
      }
    } else {
      log('NSD: No servers in the network.');
      state = state.copyWith(servers: {}, broadcastHealthMap: {});
    }
  }

  // Exposed for testing
  @visibleForTesting
  (RemoteServiceLocationConfig, BroadcastHealth?)? parseServiceForTest(
    Service service,
  ) => _parseService(service);

  /// Parse a discovered service into RemoteServiceLocationConfig and BroadcastHealth
  /// Returns a tuple of (config, broadcastHealth) or null if parsing fails
  (RemoteServiceLocationConfig, BroadcastHealth?)? _parseService(
    Service service,
  ) {
    try {
      // Extract fields - Service URLs (required)
      // Note: keys in TXT record are case insensitive in some implementations,
      // but we expect lowercase here as per our server implementation
      final authUrlBytes = service.txt?['auth_url'];
      final storeUrlBytes = service.txt?['store_url'];
      final computeUrlBytes = service.txt?['compute_url'];
      final mqttUrlBytes = service.txt?['mqtt_url'];

      // Validate all required fields exist
      if (authUrlBytes == null ||
          storeUrlBytes == null ||
          computeUrlBytes == null ||
          mqttUrlBytes == null) {
        log('Service ${service.name} missing required URL fields');
        return null;
      }

      // Convert bytes to strings
      final authUrl = String.fromCharCodes(Uint8List.fromList(authUrlBytes));
      final storeUrl = String.fromCharCodes(Uint8List.fromList(storeUrlBytes));
      final computeUrl = String.fromCharCodes(
        Uint8List.fromList(computeUrlBytes),
      );
      final mqttUrl = String.fromCharCodes(Uint8List.fromList(mqttUrlBytes));

      // Extract health status fields (optional)
      final statusBytes = service.txt?['status'];
      final broadcastStatus = statusBytes != null
          ? String.fromCharCodes(Uint8List.fromList(statusBytes))
          : null;

      final errorBytes = service.txt?['error'];
      final broadcastErrors = errorBytes != null
          ? String.fromCharCodes(Uint8List.fromList(errorBytes)).split(',')
          : null;

      // Extract identity if present (optional)
      final identityBytes = service.txt?['identifier'];
      final identity = identityBytes != null
          ? String.fromCharCodes(Uint8List.fromList(identityBytes))
          : (service.name ?? '');

      // Validate identity if present
      // Note: checking 'repo.' prefix is done by the consumer (isRepoServer),
      // here we just ensure it's a valid Cloud on LAN service
      if (!identity.endsWith('cloudonlanapps')) {
        log('Service ${service.name} has invalid identity: $identity');
        return null;
      }

      // Log broadcast health status if present
      if (broadcastStatus != null || broadcastErrors != null) {
        log(
          'Service ${service.name} broadcast health - '
          'status: $broadcastStatus, errors: $broadcastErrors',
        );
      }

      // Create ServerConfig
      final serverConfig = ServerConfig(
        authUrl: authUrl,
        storeUrl: storeUrl,
        computeUrl: computeUrl,
        mqttUrl: mqttUrl,
      );

      // Create RemoteServiceLocationConfig
      final config = RemoteServiceLocationConfig(
        serverConfig: serverConfig,
        identity: identity,
        label: service.name,
      );

      // Create BroadcastHealth if health info is present
      final broadcastHealth =
          (broadcastStatus != null || broadcastErrors != null)
          ? BroadcastHealth(
              status: broadcastStatus,
              errors: broadcastErrors,
            )
          : null;

      return (config, broadcastHealth);
    } catch (e, stackTrace) {
      log(
        'Error parsing service ${service.name}: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
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
      final notifier = NetworkScannerNotifier(serviceName: '_http._tcp');
      ref.onDispose(notifier.dispose);

      return notifier;
    });
