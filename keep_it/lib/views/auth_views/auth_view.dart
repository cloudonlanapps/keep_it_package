import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../page_manager.dart';
import '../../views/auth_views/logged_in_view.dart';
import '../../views/auth_views/logged_out_view.dart';
import '../common_widgets/action_buttons.dart';
import '../common_widgets/content_source_selector.dart';

/// Authentication view.
///
/// Displays login form when user is not authenticated,
/// and user info with logout option when authenticated.
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get currently active store using builder
    return GetActiveStore(
      builder: (activeStore) {
        final locationConfig = activeStore.entityStore.config;

        // Only show auth UI for remote stores
        if (locationConfig is! RemoteServiceLocationConfig) {
          return CLScaffold(
            topMenu: const CLTopBar(
              actions: [
                ContentSourceSelector(),
                ThemeToggleButton(),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No authentication required for local store',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          );
        }

        // Use GetAuthStatus builder to check authentication status
        return CLScaffold(
          topMenu: const CLTopBar(),
          body: GetAuthStatus(
            config: locationConfig,
            builder: (authStatus, actions) {
              if (authStatus.isAuthenticated) {
                return LoggedInView(config: locationConfig);
              } else {
                return LoggedOutView(
                  config: locationConfig,
                  onLogin: actions.login,
                );
              }
            },
            loadingBuilder: () => const CLLoadingView.local(
              debugMessage: 'Authenticating...',
            ),
            errorBuilder: (error, stack, actions) => CLErrorView.local(
              message: 'Server Error',
              details: error.toString(),
            ),
          ),
        );
      },
      loadingBuilder: () => CLLoadingView.page(
        debugMessage: 'Connecting to store...',
        actions: [
          ShadButton.outline(
            onPressed: () => PageManager.of(context).home(),
            child: const Text('Go Home'),
          ),
        ],
      ),
      errorBuilder: (error, stack) => CLErrorView.page(
        message: 'Failed to connect to store',
        details: error.toString(),
      ),
    );
  }
}
