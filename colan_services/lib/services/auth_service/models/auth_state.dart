import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:meta/meta.dart';

/// Authentication state for the application.
@immutable
class AuthState {
  const AuthState({
    this.sessionManager,
    this.currentUser,
    this.loginTimestamp,
  });

  /// Creates an initial (unauthenticated) state.
  factory AuthState.initial() {
    return const AuthState();
  }

  /// The active session manager instance.
  final SessionManager? sessionManager;

  /// Current authenticated user information.
  final UserResponse? currentUser;

  /// Timestamp when user logged in.
  final DateTime? loginTimestamp;

  /// Whether the user is authenticated.
  bool get isAuthenticated => sessionManager?.isAuthenticated ?? false;

  /// Creates a copy with updated fields.
  AuthState copyWith({
    SessionManager? sessionManager,
    UserResponse? currentUser,
    DateTime? loginTimestamp,
  }) {
    return AuthState(
      sessionManager: sessionManager ?? this.sessionManager,
      currentUser: currentUser ?? this.currentUser,
      loginTimestamp: loginTimestamp ?? this.loginTimestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          sessionManager == other.sessionManager &&
          currentUser == other.currentUser &&
          loginTimestamp == other.loginTimestamp;

  @override
  int get hashCode =>
      sessionManager.hashCode ^
      currentUser.hashCode ^
      loginTimestamp.hashCode;

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, '
        'username: ${currentUser?.username}, '
        'loginTimestamp: $loginTimestamp)';
  }
}
