import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

import '../../server_service/server_service.dart';
import '../../views/auth_views/logged_in_view.dart';
import '../../views/auth_views/logged_out_view.dart';

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
            topMenu: AppBar(),
            bottomMenu: null,
            banners: const [],
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
          topMenu: AppBar(),
          bottomMenu: null,
          banners: const [],
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
            loadingBuilder: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Authenticating...'),
                ],
              ),
            ),
            errorBuilder: (error, stack, actions) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Server Error',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loadingBuilder: () => CLScaffold(
        topMenu: AppBar(),
        bottomMenu: null,
        banners: const [],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to store...'),
            ],
          ),
        ),
      ),
      errorBuilder: (error, stack) => CLScaffold(
        topMenu: AppBar(),
        bottomMenu: null,
        banners: const [],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to connect to store',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
