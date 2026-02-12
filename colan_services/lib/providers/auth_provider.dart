import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service/models/auth_state.dart';
import '../services/auth_service/models/server_preferences.dart';
import '../services/auth_service/notifiers/auth_notifier.dart';
import '../services/auth_service/notifiers/server_preferences_notifier.dart';

/// Provider for server configuration preferences.
///
/// Manages auth, compute, store, and MQTT server URLs.
/// Persists changes to SharedPreferences.
final serverPreferencesProvider =
    StateNotifierProvider<ServerPreferencesNotifier, ServerPreferences>((ref) {
  return ServerPreferencesNotifier();
});

/// Provider for authentication state.
///
/// Manages login, logout, and token refresh.
/// Handles auto-login from saved credentials.
final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
