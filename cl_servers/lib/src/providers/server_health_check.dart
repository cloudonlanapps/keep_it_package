import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Provider definition
final AsyncNotifierProviderFamily<ServerHealthCheckNotifier, bool, CLUrl>
    serverHealthCheckProvider = AsyncNotifierProvider.family<
        ServerHealthCheckNotifier,
        bool,
        CLUrl>(ServerHealthCheckNotifier.new);

class ServerHealthCheckNotifier extends FamilyAsyncNotifier<bool, CLUrl>
    with CLLogger {
  @override
  String get logPrefix => 'ServerHealthCheck';

  static const Duration healthCheckTimeout = Duration(seconds: 5);

  @override
  FutureOr<bool> build(CLUrl arg) async {
    // Perform health check on build
    return await checkAllServices(arg);
  }

  Future<bool> checkAllServices(CLUrl server) async {
    try {
      final results = await Future.wait([
        isServiceHealthy(server.authUrl),
        isServiceHealthy(server.storeUrl),
        isServiceHealthy(server.computeUrl),
      ]);

      final allHealthy = results.every((healthy) => healthy);

      if (!allHealthy) {
        log('Health check failed for ${server.label} - '
            'Auth: ${results[0]}, Store: ${results[1]}, Compute: ${results[2]}');
      }

      return allHealthy;
    } catch (e, stackTrace) {
      log('Error checking server health: $e',
          error: e, stackTrace: stackTrace);
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
