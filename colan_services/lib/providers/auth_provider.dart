import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service/models/auth_state.dart';
import '../services/auth_service/notifiers/auth_notifier.dart';

/// Provider for authentication state.
///
/// Manages login, logout, and token refresh.
/// Handles auto-login from saved credentials.
final authStateProvider =
    AsyncNotifierProviderFamily<AuthNotifier, AuthState, CLUrl>(() {
      return AuthNotifier();
    });
