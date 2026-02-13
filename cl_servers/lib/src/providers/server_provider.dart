import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_server.dart';
import '../models/remote_service_location_config.dart';
import '../models/server_health_status.dart';
import 'network_scanner.dart';
import 'server_health_check.dart';

class ServerNotifier
    extends FamilyAsyncNotifier<CLServer, RemoteServiceLocationConfig>
    with CLLogger {
  @override
  String get logPrefix => 'ServerNotifier';

  Timer? timer;

  @override
  FutureOr<CLServer> build(RemoteServiceLocationConfig arg) async {
    try {
      final config = arg;

      // Get broadcast health from network scanner
      final scanner = ref.watch(networkScannerProvider);
      final broadcastHealth = scanner.getBroadcastHealth(config);

      // Perform our own health check
      final ourHealthCheckPassed =
          await ref.watch(serverHealthCheckProvider(config).future);

      // Create health status combining broadcast and our check
      final healthStatus = ServerHealthStatus(
        broadcastStatus: broadcastHealth?.status,
        broadcastErrors: broadcastHealth?.errors,
        lastChecked: DateTime.now(),
        ourHealthCheckPassed: ourHealthCheckPassed,
      );

      // Log if server is unhealthy
      if (!healthStatus.isHealthy) {
        if (healthStatus.hasBroadcastIssues) {
          log('Server ${config.label} reports unhealthy status: '
              'status=${healthStatus.broadcastStatus}, '
              'errors=${healthStatus.broadcastErrors}');
        }
        if (!ourHealthCheckPassed) {
          log('Server ${config.label} failed our health check');
        }
      }

      // Create CLServer with health status
      final clServer = CLServer(
        locationConfig: config,
        healthStatus: healthStatus,
        client: CLServer.defaultHttpClient,
      );

      ref.onDispose(() {
        timer?.cancel();
        timer = null;
      });

      return clServer;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Method to recheck health
  Future<void> recheckHealth() async {
    ref
      ..invalidate(serverHealthCheckProvider(arg))
      ..invalidateSelf();
  }

  /* Future<void> monitorServer(Timer _) async {
    try {
      final clServer = await state.value?.isConnected();
      final server = state.value;

      if (server != clServer) {
        state = AsyncData(clServer!);
      }
    } catch (e) {
      log('monitorServer: $e');
      rethrow;
    }
  } */
}

final serverProvider = AsyncNotifierProviderFamily<ServerNotifier, CLServer,
    RemoteServiceLocationConfig>(
  ServerNotifier.new,
);
