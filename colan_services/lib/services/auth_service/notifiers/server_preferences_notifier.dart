import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_preferences.dart';

/// Storage helper for persisting server configuration.
class _ServerConfigStorage {
  static const _keyAuthUrl = 'server_auth_url';
  static const _keyComputeUrl = 'server_compute_url';
  static const _keyStoreUrl = 'server_store_url';
  static const _keyMqttUrl = 'server_mqtt_url';

  /// Save server preferences to SharedPreferences.
  static Future<void> save(ServerPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyAuthUrl, prefs.authUrl);
    await sp.setString(_keyComputeUrl, prefs.computeUrl);
    await sp.setString(_keyStoreUrl, prefs.storeUrl);
    await sp.setString(_keyMqttUrl, prefs.mqttUrl);
  }

  /// Load server preferences from SharedPreferences.
  /// Returns default values from ~/.cl_client_config.json if not found.
  static Future<ServerPreferences> load() async {
    final sp = await SharedPreferences.getInstance();
    final defaults = ServerPreferences.defaults();

    return ServerPreferences(
      authUrl: sp.getString(_keyAuthUrl) ?? defaults.authUrl,
      computeUrl: sp.getString(_keyComputeUrl) ?? defaults.computeUrl,
      storeUrl: sp.getString(_keyStoreUrl) ?? defaults.storeUrl,
      mqttUrl: sp.getString(_keyMqttUrl) ?? defaults.mqttUrl,
    );
  }
}

/// State notifier for managing server configuration preferences.
class ServerPreferencesNotifier extends StateNotifier<ServerPreferences> {
  ServerPreferencesNotifier() : super(ServerPreferences.defaults()) {
    unawaited(_loadFromStorage());
  }

  /// Load preferences from storage on initialization.
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _ServerConfigStorage.load();
      state = prefs;
    } catch (e) {
      // If loading fails, keep default state
    }
  }

  /// Update server URLs and persist to storage.
  Future<void> updateUrls({
    String? authUrl,
    String? computeUrl,
    String? storeUrl,
    String? mqttUrl,
  }) async {
    state = state.copyWith(
      authUrl: authUrl,
      computeUrl: computeUrl,
      storeUrl: storeUrl,
      mqttUrl: mqttUrl,
    );

    await _saveToStorage();
  }

  /// Save current state to storage.
  Future<void> _saveToStorage() async {
    try {
      await _ServerConfigStorage.save(state);
    } catch (e) {
      // Handle save failure silently
    }
  }
}
