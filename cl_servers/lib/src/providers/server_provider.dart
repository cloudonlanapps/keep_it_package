import 'dart:async';
import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart' as sdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cl_server.dart';
import '../models/remote_service_location_config.dart';
import '../models/server_health_status.dart';
import 'network_scanner.dart';
import 'server_health_check.dart';

/// Storage helper for persisting user credentials.
class _CredentialStorage {
  static const _keyUsername = 'auth_username';
  static const _keyPassword = 'auth_password_encoded';
  static const _keyRemember = 'auth_remember_me';

  /// Save credentials to SharedPreferences with basic encoding.
  static Future<void> save(
    String username,
    String password, {
    required String keySuffix,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyUsername:$keySuffix', username);
    await prefs.setString(
      '$_keyPassword:$keySuffix',
      base64Encode(utf8.encode(password)),
    );
    await prefs.setBool('$_keyRemember:$keySuffix', true);
  }

  /// Load saved credentials from SharedPreferences.
  /// Returns null if no credentials or user didn't opt for remember me.
  static Future<(String, String)?> load({required String keySuffix}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('$_keyRemember:$keySuffix') != true) return null;

    final username = prefs.getString('$_keyUsername:$keySuffix');
    final passwordEncoded = prefs.getString('$_keyPassword:$keySuffix');
    if (username == null || passwordEncoded == null) return null;

    final password = utf8.decode(base64Decode(passwordEncoded));
    return (username, password);
  }

  /// Clear saved credentials from SharedPreferences.
  static Future<void> clear({required String keySuffix}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyUsername:$keySuffix');
    await prefs.remove('$_keyPassword:$keySuffix');
    await prefs.remove('$_keyRemember:$keySuffix');
  }
}

class ServerNotifier
    extends FamilyAsyncNotifier<CLServer, RemoteServiceLocationConfig>
    with CLLogger {
  @override
  String get logPrefix => 'ServerNotifier';

  Timer? _healthCheckTimer;
  Timer? _tokenRefreshTimer;

  String get _keySuffix => arg.identity;

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

      // Auth state (only if server is healthy)
      sdk.SessionManager? sessionManager;
      sdk.UserResponse? currentUser;
      DateTime? loginTimestamp;
      sdk.StoreManager? storeManager;

      if (healthStatus.isHealthy) {
        // Try auto-login from saved credentials
        final credentials =
            await _CredentialStorage.load(keySuffix: _keySuffix);
        if (credentials != null) {
          try {
            sessionManager = sdk.SessionManager(serverConfig: config.serverConfig);
            await sessionManager.login(credentials.$1, credentials.$2);
            currentUser = await sessionManager.getCurrentUser();
            loginTimestamp = DateTime.now();

            // Create StoreManager automatically
            storeManager = sessionManager.createStoreManager();

            // Start token refresh timer
            _startTokenRefreshTimer(sessionManager);

            log('Auto-login successful for ${config.label}');
          } catch (e) {
            log('Auto-login failed: $e');
            await _CredentialStorage.clear(keySuffix: _keySuffix);
          }
        }
      } else {
        log('Server ${config.label} is unhealthy, skipping auth');
      }

      // Create CLServer with all state
      final clServer = CLServer(
        locationConfig: config,
        healthStatus: healthStatus,
        client: CLServer.defaultHttpClient,
        sessionManager: sessionManager,
        currentUser: currentUser,
        loginTimestamp: loginTimestamp,
        storeManager: storeManager,
      );

      ref.onDispose(() {
        _healthCheckTimer?.cancel();
        _tokenRefreshTimer?.cancel();
        storeManager?.close(); // Cleanup StoreManager
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

  /// Login with username and password (replaces AuthNotifier.login).
  Future<void> login(
    String username,
    String password, {
    required bool rememberMe,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentServer = await future;

      if (!currentServer.connected) {
        throw Exception('Server not connected');
      }

      final sessionManager = sdk.SessionManager(serverConfig: arg.serverConfig);
      await sessionManager.login(username, password);
      final user = await sessionManager.getCurrentUser();

      if (rememberMe) {
        await _CredentialStorage.save(
          username,
          password,
          keySuffix: _keySuffix,
        );
      }

      // Create StoreManager automatically
      final storeManager = sessionManager.createStoreManager();

      // Start token refresh timer
      _startTokenRefreshTimer(sessionManager);

      return currentServer.copyWith(
        sessionManager: () => sessionManager,
        currentUser: () => user,
        loginTimestamp: () => DateTime.now(),
        storeManager: () => storeManager,
      );
    });
  }

  /// Logout and optionally clear saved credentials (replaces AuthNotifier.logout).
  Future<void> logout({bool clearCredentials = true}) async {
    _stopTokenRefreshTimer();

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentServer = await future;

      // Close StoreManager first
      await currentServer.storeManager?.close();

      // Logout SessionManager
      await currentServer.sessionManager?.logout();

      if (clearCredentials) {
        await _CredentialStorage.clear(keySuffix: _keySuffix);
      }

      return currentServer.copyWith(
        sessionManager: () => null,
        currentUser: () => null,
        loginTimestamp: () => null,
        storeManager: () => null,
      );
    });
  }

  /// Start periodic timer to refresh token and keep session alive.
  ///
  /// Calls getValidToken() every 30 seconds. Since tokens expire at 60 seconds,
  /// this provides a 30-second safety margin.
  void _startTokenRefreshTimer(sdk.SessionManager sessionManager) {
    _stopTokenRefreshTimer();

    _tokenRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        try {
          await sessionManager.getValidToken();
        } catch (e) {
          log('Token refresh failed: $e');
          await logout();
        }
      },
    );
  }

  /// Stop the token refresh timer.
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
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
