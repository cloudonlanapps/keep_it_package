import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../server_service/server_service.dart';
import '../basic_page_service/widgets/fullscreen_layout.dart';
import 'views/logged_in_view.dart';
import 'views/logged_out_view.dart';

/// Authentication service page.
///
/// Displays login form when user is not authenticated,
/// and user info with logout option when authenticated.
class AuthService extends ConsumerWidget {
  const AuthService({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get currently active store
    final activeStoreAsync = ref.watch(activeStoreProvider);

    return FullscreenLayout(
      child: activeStoreAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to store...'),
            ],
          ),
        ),
        error: (error, stack) => LoggedOutView(
          errorMessage: 'Failed to connect to store: $error',
          // If we fail to get active store, we can't really do much login-wise
          // unless we have a fallback or empty config which might not make sense.
          // For now, we show error but user can't login without a valid server target.
          config: null,
        ),
        data: (activeStore) {
          final locationConfig = activeStore.entityStore.config;

          // Only show auth UI for remote stores
          if (locationConfig is! RemoteServiceLocationConfig) {
            return Center(
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
            );
          }

          // Use serverProvider with .select() to only watch authentication status
          final serverAsync = ref.watch(serverProvider(locationConfig));

          return serverAsync.when(
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Authenticating...'),
                ],
              ),
            ),
            error: (error, stack) => LoggedOutView(
              errorMessage: error.toString(),
              config: locationConfig,
            ),
            data: (server) {
              if (server.isAuthenticated) {
                return LoggedInView(config: locationConfig);
              } else {
                return LoggedOutView(config: locationConfig);
              }
            },
          );
        },
      ),
    );
  }
}
