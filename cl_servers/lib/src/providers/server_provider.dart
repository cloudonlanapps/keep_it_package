import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_server.dart';
import 'server_health_check.dart';

class ServerNotifier extends FamilyAsyncNotifier<CLServer, CLUrl>
    with CLLogger {
  @override
  String get logPrefix => 'ServerNotifier';

  Timer? timer;

  @override
  FutureOr<CLServer> build(CLUrl arg) async {
    try {
      // Check if server reports itself as unhealthy via broadcast
      final hasBroadcastIssues = arg.hasBroadcastIssues;

      // Perform our own health check
      final ourHealthCheckPassed =
          await ref.watch(serverHealthCheckProvider(arg).future);

      // Server is connected ONLY if:
      // 1. Broadcast doesn't report unhealthy status
      // 2. Our health check passes
      final isConnected = !hasBroadcastIssues && ourHealthCheckPassed;

      if (!isConnected) {
        if (hasBroadcastIssues) {
          log('Server ${arg.label} reports unhealthy status: '
              'status=${arg.broadcastStatus}, errors=${arg.broadcastErrors}');
        }
        if (!ourHealthCheckPassed) {
          log('Server ${arg.label} failed our health check');
        }
      }

      // Create CLServer with combined health status
      final clServer = CLServer(
        storeURL: arg,
        connected: isConnected,
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

final serverProvider =
    AsyncNotifierProviderFamily<ServerNotifier, CLServer, CLUrl>(
      ServerNotifier.new,
    );
