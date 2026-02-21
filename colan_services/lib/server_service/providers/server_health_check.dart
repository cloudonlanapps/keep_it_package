import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Provider definition
final AsyncNotifierProviderFamily<
  ServerHealthCheckNotifier,
  bool,
  RemoteServiceLocationConfig
>
serverHealthCheckProvider =
    AsyncNotifierProvider.family<
      ServerHealthCheckNotifier,
      bool,
      RemoteServiceLocationConfig
    >(ServerHealthCheckNotifier.new);

class ServerHealthCheckNotifier
    extends FamilyAsyncNotifier<bool, RemoteServiceLocationConfig>
    with CLLogger {
  @override
  String get logPrefix => 'ServerHealthCheck';

  static const Duration healthCheckTimeout = Duration(seconds: 5);
  static const Duration healthCheckInterval = Duration(seconds: 15);

  Timer? _periodicTimer;

  @override
  FutureOr<bool> build(RemoteServiceLocationConfig arg) async {
    // Cancel any existing timer
    _periodicTimer?.cancel();

    // Register cleanup
    ref.onDispose(() {
      _periodicTimer?.cancel();
      _periodicTimer = null;
    });

    // Start periodic health check timer
    _startPeriodicHealthCheck();

    // Perform health check on build
    return await checkAllServices(arg);
  }

  /// Start periodic health check that only updates state if result changes.
  void _startPeriodicHealthCheck() {
    _periodicTimer = Timer.periodic(healthCheckInterval, (_) async {
      try {
        // Check health without triggering full rebuild
        final newHealthy = await checkAllServices(arg);
        final currentHealthy = state.valueOrNull;

        // Only update state if health status actually changed
        if (currentHealthy != newHealthy) {
          log(
            'Health status changed: $currentHealthy -> $newHealthy',
          );
          state = AsyncValue.data(newHealthy);
        }
      } catch (e) {
        log('Periodic health check error: $e');
        // If we were healthy and now errored, update state
        if (state.valueOrNull == true) {
          state = const AsyncValue.data(false);
        }
      }
    });
  }

  Future<bool> checkAllServices(RemoteServiceLocationConfig config) async {
    try {
      final results = await Future.wait([
        isServiceHealthy(config.authUrl),
        isServiceHealthy(config.storeUrl),
        isServiceHealthy(config.computeUrl),
      ]);

      log(
        'Health check results for ${config.label}: Auth: ${results[0]}, Store: ${results[1]}, Compute: ${results[2]}',
      );
      final allHealthy = results.every((healthy) => healthy);

      if (!allHealthy) {
        log(
          'Health check failed for ${config.label} - '
          'Auth: ${results[0]}, Store: ${results[1]}, Compute: ${results[2]}',
        );
      }

      return allHealthy;
    } catch (e, stackTrace) {
      log('Error checking server health: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> isServiceHealthy(String serviceUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$serviceUrl/'))
          .timeout(healthCheckTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      log('Health check failed for $serviceUrl: $e');
      return false;
    }
  }

  // Method to manually trigger health check
  Future<void> recheckHealth() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => checkAllServices(arg));
  }
}
