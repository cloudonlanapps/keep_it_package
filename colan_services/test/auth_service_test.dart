import 'dart:convert';
import 'dart:io';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Load server configuration from ~/.cl_client_config.json
ServerConfig _loadServerConfig() {
  final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
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

  final configJson = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
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
  final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (homeDir == null) {
    throw Exception('Cannot determine home directory');
  }

  final configPath = p.join(homeDir, '.cl_client_config.json');
  final configFile = File(configPath);

  if (!configFile.existsSync()) {
    return 'admin'; // fallback
  }

  final configJson = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  return configJson['username'] as String? ?? 'admin';
}

void main() {
  // Load test configuration from ~/.cl_client_config.json
  // Server URLs and username are loaded from the config file.
  // Update the password below to match your test user's password.
  late ServerConfig testServerConfig;
  late String testUsername;
  const testPassword = 'admin';

  setUpAll(() {
    testServerConfig = _loadServerConfig();
    testUsername = _loadTestUsername();
    print('Using server config: ${testServerConfig.authUrl}');
    print('Using username: $testUsername');
  });

  group('SessionManager Integration', () {
    test('login with valid credentials', () async {
      final sessionManager = SessionManager(serverConfig: testServerConfig);

      final result = await sessionManager.login(testUsername, testPassword);

      expect(result.accessToken, isNotEmpty);
      expect(sessionManager.isAuthenticated, isTrue);

      await sessionManager.logout();
    });

    test('login with invalid credentials throws exception', () async {
      final sessionManager = SessionManager(serverConfig: testServerConfig);

      expect(
        () => sessionManager.login('invalid', 'invalid'),
        throwsException,
      );
    });

    test('token refresh keeps session alive', () async {
      final sessionManager = SessionManager(serverConfig: testServerConfig);

      await sessionManager.login(testUsername, testPassword);
      expect(sessionManager.isAuthenticated, isTrue);

      // Get initial token
      final _ = sessionManager.getToken();

      // Wait a bit and call getValidToken
      await Future<void>.delayed(const Duration(seconds: 2));
      final validToken = await sessionManager.getValidToken();

      // Token might be refreshed or same depending on expiry
      expect(validToken, isNotEmpty);
      expect(sessionManager.isAuthenticated, isTrue);

      await sessionManager.logout();
    });

    test('logout clears session', () async {
      final sessionManager = SessionManager(serverConfig: testServerConfig);

      await sessionManager.login(testUsername, testPassword);
      expect(sessionManager.isAuthenticated, isTrue);

      await sessionManager.logout();
      expect(sessionManager.isAuthenticated, isFalse);
      expect(sessionManager.getToken, throwsStateError);
    });

    test('get current user returns user info', () async {
      final sessionManager = SessionManager(serverConfig: testServerConfig);

      await sessionManager.login(testUsername, testPassword);
      final user = await sessionManager.getCurrentUser();

      expect(user, isNotNull);
      expect(user!.username, equals(testUsername));
      expect(user.id, isPositive);

      await sessionManager.logout();
    });
  });

  group('Credential Storage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and load credentials', () async {
      const username = 'testuser';
      const password = 'testpass';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_username', username);
      await prefs.setString(
        'auth_password_encoded',
        base64Encode(utf8.encode(password)),
      );
      await prefs.setBool('auth_remember_me', true);

      // Load credentials
      final loadedUsername = prefs.getString('auth_username');
      final loadedPasswordEncoded = prefs.getString('auth_password_encoded');
      final rememberMe = prefs.getBool('auth_remember_me');

      expect(loadedUsername, equals(username));
      expect(rememberMe, isTrue);

      final loadedPassword =
          utf8.decode(base64Decode(loadedPasswordEncoded!));
      expect(loadedPassword, equals(password));
    });

    test('clear credentials', () async {
      const username = 'testuser';
      const password = 'testpass';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_username', username);
      await prefs.setString(
        'auth_password_encoded',
        base64Encode(utf8.encode(password)),
      );
      await prefs.setBool('auth_remember_me', true);

      // Clear credentials
      await prefs.remove('auth_username');
      await prefs.remove('auth_password_encoded');
      await prefs.remove('auth_remember_me');

      expect(prefs.getString('auth_username'), isNull);
      expect(prefs.getString('auth_password_encoded'), isNull);
      expect(prefs.getBool('auth_remember_me'), isNull);
    });
  });

  group('Server Configuration Storage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and load server config', () async {
      const authUrl = 'http://test-auth:8010';
      const computeUrl = 'http://test-compute:8012';
      const storeUrl = 'http://test-store:8011';
      const mqttUrl = 'mqtt://test-mqtt:1883';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_auth_url', authUrl);
      await prefs.setString('server_compute_url', computeUrl);
      await prefs.setString('server_store_url', storeUrl);
      await prefs.setString('server_mqtt_url', mqttUrl);

      // Load server config
      final loadedAuthUrl = prefs.getString('server_auth_url');
      final loadedComputeUrl = prefs.getString('server_compute_url');
      final loadedStoreUrl = prefs.getString('server_store_url');
      final loadedMqttUrl = prefs.getString('server_mqtt_url');

      expect(loadedAuthUrl, equals(authUrl));
      expect(loadedComputeUrl, equals(computeUrl));
      expect(loadedStoreUrl, equals(storeUrl));
      expect(loadedMqttUrl, equals(mqttUrl));
    });

    test('load defaults from config file when not set', () async {
      final prefs = await SharedPreferences.getInstance();

      // Load defaults from ~/.cl_client_config.json
      final defaults = _loadServerConfig();

      final authUrl = prefs.getString('server_auth_url') ?? defaults.authUrl;
      final computeUrl = prefs.getString('server_compute_url') ?? defaults.computeUrl;
      final storeUrl = prefs.getString('server_store_url') ?? defaults.storeUrl;
      final mqttUrl = prefs.getString('server_mqtt_url') ?? defaults.mqttUrl;

      // Should match values from config file
      expect(authUrl, equals(defaults.authUrl));
      expect(computeUrl, equals(defaults.computeUrl));
      expect(storeUrl, equals(defaults.storeUrl));
      expect(mqttUrl, equals(defaults.mqttUrl));
    });
  });
}
