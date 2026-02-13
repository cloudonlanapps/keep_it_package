import 'package:cl_servers/cl_servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service/models/auth_state.dart';
import '../services/auth_service/notifiers/auth_notifier.dart';

/// Provider for authentication state.
///
/// Manages login, logout, and token refresh.
/// Handles auto-login from saved credentials.
final authStateProvider = AsyncNotifierProviderFamily<AuthNotifier, AuthState,
    RemoteServiceLocationConfig>(() {
  return AuthNotifier();
});
