/* import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/server_service/server_service.dart';
import 'package:colan_services/providers/auth_provider.dart';
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
  late RemoteServiceLocationConfig testConfig;
  late String testUsername;
  const testPassword = 'admin';

  setUpAll(() {
    testServerConfig = _loadServerConfig();
    testConfig = RemoteServiceLocationConfig(
      serverConfig: testServerConfig,
      identity: 'test-server',
      label: 'Test Server',
    );
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
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = await container.read(
        authStateProvider(testConfig).future,
      );

      expect(authState.isAuthenticated, isFalse);
      expect(authState.sessionManager, isNull);
      expect(authState.currentUser, isNull);
    });

    test('login with valid credentials succeeds', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Perform login
      await container
          .read(authStateProvider(testConfig).notifier)
          .login(testUsername, testPassword, rememberMe: false);

      final authState = await container.read(
        authStateProvider(testConfig).future,
      );

      expect(authState.isAuthenticated, isTrue);
      expect(authState.sessionManager, isNotNull);
      expect(authState.currentUser, isNotNull);
      expect(authState.currentUser!.username, equals(testUsername));
      expect(authState.loginTimestamp, isNotNull);

      // Cleanup
      await container.read(authStateProvider(testConfig).notifier).logout();
    });

    test('login with invalid credentials fails', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Perform login with invalid credentials
      await container
          .read(authStateProvider(testConfig).notifier)
          .login('invalid', 'invalid', rememberMe: false);

      final authState = container.read(authStateProvider(testConfig));

      // Should be in error state
      expect(authState.hasError, isTrue);
      expect(authState.error, isNotNull);
    });

    test('logout clears authentication state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Login first
      await container
          .read(authStateProvider(testConfig).notifier)
          .login(testUsername, testPassword, rememberMe: false);

      var authState = await container.read(
        authStateProvider(testConfig).future,
      );
      expect(authState.isAuthenticated, isTrue);

      // Logout
      await container.read(authStateProvider(testConfig).notifier).logout();

      authState = await container.read(authStateProvider(testConfig).future);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.sessionManager, isNull);
      expect(authState.currentUser, isNull);
    });

    test('remember me saves credentials', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Login with remember me
      await container
          .read(authStateProvider(testConfig).notifier)
          .login(testUsername, testPassword, rememberMe: true);

      // Check credentials are saved with keySuffix
      final keySuffix = testConfig.identity;
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_username:$keySuffix'), equals(testUsername));
      expect(prefs.getString('auth_password_encoded:$keySuffix'), isNotNull);
      expect(prefs.getBool('auth_remember_me:$keySuffix'), isTrue);

      // Cleanup
      await container.read(authStateProvider(testConfig).notifier).logout();
    });

    test('logout with clearCredentials removes saved credentials', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Login with remember me
      await container
          .read(authStateProvider(testConfig).notifier)
          .login(testUsername, testPassword, rememberMe: true);

      final keySuffix = testConfig.identity;
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('auth_remember_me:$keySuffix'), isTrue);

      // Logout and clear credentials
      await container.read(authStateProvider(testConfig).notifier).logout();

      prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_username:$keySuffix'), isNull);
      expect(prefs.getString('auth_password_encoded:$keySuffix'), isNull);
      expect(prefs.getBool('auth_remember_me:$keySuffix'), isNull);
    });
  });
}
 */
