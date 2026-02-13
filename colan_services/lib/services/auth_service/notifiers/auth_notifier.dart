import 'dart:async';
import 'dart:convert';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/auth_provider.dart';
import '../models/auth_state.dart';

/// Storage helper for persisting user credentials.
class _CredentialStorage {
  static const _keyUsername = 'auth_username';
  static const _keyPassword = 'auth_password_encoded';
  static const _keyRemember = 'auth_remember_me';

  /// Save credentials to SharedPreferences with basic encoding.
  static Future<void> save(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(
      _keyPassword,
      base64Encode(utf8.encode(password)),
    );
    await prefs.setBool(_keyRemember, true);
  }

  /// Load saved credentials from SharedPreferences.
  /// Returns null if no credentials or user didn't opt for remember me.
  static Future<(String, String)?> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyRemember) != true) return null;

    final username = prefs.getString(_keyUsername);
    final passwordEncoded = prefs.getString(_keyPassword);
    if (username == null || passwordEncoded == null) return null;

    final password = utf8.decode(base64Decode(passwordEncoded));
    return (username, password);
  }

  /// Clear saved credentials from SharedPreferences.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyRemember);
  }
}

/// Authentication notifier managing login, logout, and token refresh.
class AuthNotifier extends AsyncNotifier<AuthState> {
  Timer? _tokenRefreshTimer;

  @override
  Future<AuthState> build() async {
    // Try auto-login from saved credentials
    final credentials = await _CredentialStorage.load();
    if (credentials != null) {
      try {
        final serverPrefs = ref.read(serverPreferencesProvider);
        final serverConfig = serverPrefs.toServerConfig();

        final sessionManager = SessionManager(serverConfig: serverConfig);
        await sessionManager.login(credentials.$1, credentials.$2);
        final user = await sessionManager.getCurrentUser();

        // Start token refresh timer for auto-login
        _startTokenRefreshTimer();

        return AuthState(
          sessionManager: sessionManager,
          currentUser: user,
          loginTimestamp: DateTime.now(),
        );
      } catch (e) {
        // Auto-login failed, clear credentials and show login screen
        await _CredentialStorage.clear();
      }
    }

    return AuthState.initial();
  }

  /// Login with username and password.
  Future<void> login(
    String username,
    String password, {
    required bool rememberMe,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Get server config from provider
      final serverPrefs = ref.read(serverPreferencesProvider);
      final serverConfig = serverPrefs.toServerConfig();

      final sessionManager = SessionManager(serverConfig: serverConfig);
      await sessionManager.login(username, password);
      final user = await sessionManager.getCurrentUser();

      if (rememberMe) {
        await _CredentialStorage.save(username, password);
      }

      // Start token refresh timer
      _startTokenRefreshTimer();

      return AuthState(
        sessionManager: sessionManager,
        currentUser: user,
        loginTimestamp: DateTime.now(),
      );
    });
  }

  /// Logout and optionally clear saved credentials.
  Future<void> logout({bool clearCredentials = true}) async {
    // Stop token refresh timer first
    _stopTokenRefreshTimer();

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await state.value?.sessionManager?.logout();
      if (clearCredentials) {
        await _CredentialStorage.clear();
      }
      return AuthState.initial();
    });
  }

  /// Start periodic timer to refresh token and keep session alive.
  ///
  /// Calls getValidToken() every 30 seconds. Since tokens expire at 60 seconds,
  /// this provides a 30-second safety margin.
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer();

    // Call getValidToken every 30 seconds to refresh before expiry
    _tokenRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        try {
          final currentState = state.value;
          if (currentState?.sessionManager != null) {
            await currentState!.sessionManager!.getValidToken();
          }
        } catch (e) {
          // Token refresh failed - probably expired or network error
          // Force logout
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
}
