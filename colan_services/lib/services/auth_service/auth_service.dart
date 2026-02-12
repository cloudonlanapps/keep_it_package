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
    final authAsync = ref.watch(authStateProvider);

    return FullscreenLayout(
      useSafeArea: true,
      child: authAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
        error: (error, stack) => LoggedOutView(
          errorMessage: error.toString(),
        ),
        data: (authState) {
          if (authState.isAuthenticated) {
            return const LoggedInView();
          } else {
            return const LoggedOutView();
          }
        },
      ),
    );
  }
}
