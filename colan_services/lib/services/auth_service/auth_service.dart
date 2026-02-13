import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:content_store/src/stores/providers/active_store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/fullscreen_layout.dart';
import '../../providers/auth_provider.dart';
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
          // unless we have a fallback or empty CLUrl which might not make sense.
          // For now, we show error but user can't login without a valid server target.
          clUrl: null,
        ),
        data: (activeStore) {
          final clUrl = activeStore.store.storeURL;
          final authAsync = ref.watch(authStateProvider(clUrl));

          return authAsync.when(
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
              clUrl: clUrl,
            ),
            data: (authState) {
              if (authState.isAuthenticated) {
                return LoggedInView(clUrl: clUrl);
              } else {
                return LoggedOutView(clUrl: clUrl);
              }
            },
          );
        },
      ),
    );
  }
}
