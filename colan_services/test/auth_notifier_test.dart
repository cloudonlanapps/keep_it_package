import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/providers/auth_provider.dart';
import 'package:colan_services/services/auth_service/notifiers/server_preferences_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Load server configuration from ~/.cl_client_config.json
ServerConfig _loadServerConfig() {
  final homeDir =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (homeDir == null) {
    throw Exception('Cannot determine home directory');
  }

  final configPath = p.join(homeDir, '.cl_client_config.json');
  final configFile = File(configPath);

  if (!configFile.existsSync()) {
    throw Exception(
      'Config file not found at $configPath. '
      'Please create ~/.cl_client_config.json with server configuration.',
    );
  }

  final configJson =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final serverPref = configJson['server_pref'] as Map<String, dynamic>;

  return ServerConfig(
    authUrl: serverPref['auth_url'] as String,
    computeUrl: serverPref['compute_url'] as String,
    storeUrl: serverPref['store_url'] as String,
    mqttUrl: serverPref['mqtt_url'] as String,
  );
}

/// Load test credentials from ~/.cl_client_config.json
String _loadTestUsername() {
  final homeDir =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (homeDir == null) {
    throw Exception('Cannot determine home directory');
  }

  final configPath = p.join(homeDir, '.cl_client_config.json');
  final configFile = File(configPath);

  if (!configFile.existsSync()) {
    return 'admin'; // fallback
  }

  final configJson =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  return configJson['username'] as String? ?? 'admin';
}

void main() {
  late ServerConfig testServerConfig;
  late String testUsername;
  const testPassword = 'admin';

  setUpAll(() {
    testServerConfig = _loadServerConfig();
    testUsername = _loadTestUsername();
    
    dev.log('Using server config: ${testServerConfig.authUrl}');
    
    dev.log('Using username: $testUsername');
  });

  setUp(() async {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthNotifier', () {
    test('initial state is unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          serverPreferencesProvider.overrideWith(
            (ref) {
              final notifier = ServerPreferencesNotifier();
              unawaited(
                notifier.updateUrls(
                  authUrl: testServerConfig.authUrl,
                  computeUrl: testServerConfig.computeUrl,
                  storeUrl: testServerConfig.storeUrl,
                  mqttUrl: testServerConfig.mqttUrl,
                ),
              );
              return notifier;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      final authState = await container.read(authStateProvider.future);

      expect(authState.isAuthenticated, isFalse);
      expect(authState.sessionManager, isNull);
      expect(authState.currentUser, isNull);
    });

    test('login with valid credentials succeeds', () async {
      final container = ProviderContainer(
        overrides: [
          serverPreferencesProvider.overrideWith(
            (ref) {
              final notifier = ServerPreferencesNotifier();
              unawaited(
                notifier.updateUrls(
                  authUrl: testServerConfig.authUrl,
                  computeUrl: testServerConfig.computeUrl,
                  storeUrl: testServerConfig.storeUrl,
                  mqttUrl: testServerConfig.mqttUrl,
                ),
              );
              return notifier;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      // Perform login
      await container
          .read(authStateProvider.notifier)
          .login(testUsername, testPassword, rememberMe: false);

      final authState = await container.read(authStateProvider.future);

      expect(authState.isAuthenticated, isTrue);
      expect(authState.sessionManager, isNotNull);
      expect(authState.currentUser, isNotNull);
      expect(authState.currentUser!.username, equals(testUsername));
      expect(authState.loginTimestamp, isNotNull);

      // Cleanup
      await container.read(authStateProvider.notifier).logout();
    });

    test('login with invalid credentials fails', () async {
      final container = ProviderContainer(
        overrides: [
          serverPreferencesProvider.overrideWith(
            (ref) {
              final notifier = ServerPreferencesNotifier();
              unawaited(
                notifier.updateUrls(
                  authUrl: testServerConfig.authUrl,
                  computeUrl: testServerConfig.computeUrl,
                  storeUrl: testServerConfig.storeUrl,
                  mqttUrl: testServerConfig.mqttUrl,
                ),
              );
              return notifier;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      // Perform login with invalid credentials
      await container
          .read(authStateProvider.notifier)
          .login('invalid', 'invalid', rememberMe: false);

      final authState = container.read(authStateProvider);

      // Should be in error state
      expect(authState.hasError, isTrue);
      expect(authState.error, isNotNull);
    });

    test('logout clears authentication state', () async {
      final container = ProviderContainer(
        overrides: [
          serverPreferencesProvider.overrideWith(
            (ref) {
              final notifier = ServerPreferencesNotifier();
              unawaited(
                notifier.updateUrls(
                  authUrl: testServerConfig.authUrl,
                  computeUrl: testServerConfig.computeUrl,
                  storeUrl: testServerConfig.storeUrl,
                  mqttUrl: testServerConfig.mqttUrl,
                ),
              );
              return notifier;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      // Login first
      await container
          .read(authStateProvider.notifier)
          .login(testUsername, testPassword, rememberMe: false);

      var authState = await container.read(authStateProvider.future);
      expect(authState.isAuthenticated, isTrue);

      // Logout
      await container.read(authStateProvider.notifier).logout();

      authState = await container.read(authStateProvider.future);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.sessionManager, isNull);
      expect(authState.currentUser, isNull);
    });

    test('remember me saves credentials', () async {
      final container = ProviderContainer(
        overrides: [
          serverPreferencesProvider.overrideWith(
            (ref) {
              final notifier = ServerPreferencesNotifier();
              unawaited(
                notifier.updateUrls(
                  authUrl: testServerConfig.authUrl,
                  computeUrl: testServerConfig.computeUrl,
                  storeUrl: testServerConfig.storeUrl,
                  mqttUrl: testServerConfig.mqttUrl,
                ),
              );
              return notifier;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      // Login with remember me
      await container
          .read(authStateProvider.notifier)
          .login(testUsername, testPassword, rememberMe: true);

      // Check credentials are saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_username'), equals(testUsername));
      expect(prefs.getString('auth_password_encoded'), isNotNull);
      expect(prefs.getBool('auth_remember_me'), isTrue);

      // Cleanup
      await container
          .read(authStateProvider.notifier)
          .logout();
    });

    test('logout with clearCredentials removes saved credentials', () async {
      final container = ProviderContainer(
        overrides: [
          serverPreferencesProvider.overrideWith(
            (ref) {
              final notifier = ServerPreferencesNotifier();
              unawaited(
                notifier.updateUrls(
                  authUrl: testServerConfig.authUrl,
                  computeUrl: testServerConfig.computeUrl,
                  storeUrl: testServerConfig.storeUrl,
                  mqttUrl: testServerConfig.mqttUrl,
                ),
              );
              return notifier;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      // Login with remember me
      await container
          .read(authStateProvider.notifier)
          .login(testUsername, testPassword, rememberMe: true);

      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('auth_remember_me'), isTrue);

      // Logout and clear credentials
      await container
          .read(authStateProvider.notifier)
          .logout();

      prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_username'), isNull);
      expect(prefs.getString('auth_password_encoded'), isNull);
      expect(prefs.getBool('auth_remember_me'), isNull);
    });
  });

  group('ServerPreferencesNotifier', () {
    test('initial state loads from config file', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final prefs = container.read(serverPreferencesProvider);

      // Should have loaded from ~/.cl_client_config.json
      expect(prefs.authUrl, isNotEmpty);
      expect(prefs.computeUrl, isNotEmpty);
      expect(prefs.storeUrl, isNotEmpty);
      expect(prefs.mqttUrl, isNotEmpty);
    });
  });
}
