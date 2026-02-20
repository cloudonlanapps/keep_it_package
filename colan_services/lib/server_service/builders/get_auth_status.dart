import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/server_provider.dart';

/// Immutable data class containing authentication status information.
@immutable
class AuthStatusData {
  const AuthStatusData({
    required this.isAuthenticated,
    required this.username,
    required this.loginTime,
    required this.authUrl,
    required this.isAdmin,
    required this.permissions,
    required this.createdAt,
  });

  final bool isAuthenticated;
  final String? username;
  final DateTime? loginTime;
  final String authUrl;
  final bool isAdmin;
  final List<String> permissions;
  final DateTime? createdAt;
}

/// Immutable class encapsulating authentication actions.
@immutable
class AuthActions {
  const AuthActions({
    required this.logout,
    required this.login,
  });

  final Future<void> Function() logout;
  final Future<void> Function(
    String username,
    String password, {
    required bool rememberMe,
  })
  login;
}

/// Builder widget that watches serverProvider and exposes authentication status.
///
/// This builder decouples views from direct provider access by providing
/// authentication data and actions through callback parameters.
///
/// Example usage:
/// ```dart
/// GetAuthStatus(
///   config: config,
///   builder: (authStatus, actions) {
///     return Column(
///       children: [
///         Text(authStatus.username ?? 'Not logged in'),
///         ElevatedButton(
///           onPressed: actions.logout,
///           child: Text('Logout'),
///         ),
///       ],
///     );
///   },
///   loadingBuilder: () => CircularProgressIndicator(),
///   errorBuilder: (e, st) => ErrorView(error: e),
/// )
/// ```
class GetAuthStatus extends ConsumerWidget {
  const GetAuthStatus({
    required this.config,
    required this.builder,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });

  final RemoteServiceLocationConfig config;
  final Widget Function(AuthStatusData, AuthActions) builder;
  final CLLoadingView Function() loadingBuilder;
  final CLErrorView Function(Object, StackTrace, AuthActions) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create actions that work regardless of server state
    final actions = AuthActions(
      logout: () => ref.read(serverProvider(config).notifier).logout(),
      login: (username, password, {required rememberMe}) => ref
          .read(serverProvider(config).notifier)
          .login(username, password, rememberMe: rememberMe),
    );

    final serverAsync = ref.watch(serverProvider(config));
    return serverAsync.when(
      data: (server) {
        final data = AuthStatusData(
          isAuthenticated: server.isAuthenticated,
          username: server.currentUser?.username,
          loginTime: server.loginTimestamp,
          authUrl: config.authUrl,
          isAdmin: server.currentUser?.isAdmin ?? false,
          permissions: server.currentUser?.permissions ?? const [],
          createdAt: server.currentUser?.createdAt,
        );
        return builder(data, actions);
      },
      loading: loadingBuilder,
      error: (error, stack) => errorBuilder(error, stack, actions),
    );
  }
}
