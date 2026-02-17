import 'dart:async';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../page_manager.dart';

/// View displayed when user is logged in.
///
/// This view is decoupled from Riverpod - it receives auth data and actions
/// through the GetAuthStatus builder, making it a pure UI widget.
class LoggedInView extends StatelessWidget {
  const LoggedInView({
    required this.config,
    super.key,
  });

  final RemoteServiceLocationConfig config;

  @override
  Widget build(BuildContext context) {
    return GetAuthStatus(
      config: config,
      builder: (authStatus, actions) {
        if (!authStatus.isAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final loginTimeStr = authStatus.loginTime != null
            ? authStatus.loginTime!.toString().substring(0, 19)
            : 'Unknown';

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Signed In',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(
                    context,
                    icon: Icons.person,
                    label: 'Username',
                    value: authStatus.username ?? 'Unknown',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.access_time,
                    label: 'Logged in at',
                    value: loginTimeStr,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.dns,
                    label: 'Auth Server',
                    value: authStatus.authUrl,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => PageManager.of(context).home(),
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Home Screen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _handleLogout(context, actions.logout),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loadingBuilder: () => const CLLoadingView.local(
        debugMessage: 'LoggedInView',
      ),
      errorBuilder: (error, stackTrace, actions) => CLErrorView.local(
        message: 'Error loading auth status',
        details: error.toString(),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    Future<void> Function() logout,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(logout());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
