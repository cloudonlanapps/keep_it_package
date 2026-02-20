import 'dart:async';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
                    style: ShadTheme.of(context).textTheme.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Server: ${config.displayName}',
                    style: ShadTheme.of(context).textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  _buildSimpleInfo(
                    context,
                    icon: Icons.person_outline,
                    label: 'Username',
                    value: authStatus.username ?? 'Unknown',
                  ),
                  const Divider(height: 32),
                  _buildSimpleInfo(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Member since',
                    value: authStatus.createdAt != null
                        ? authStatus.createdAt!.toString().substring(0, 10)
                        : 'Unknown',
                  ),
                  const Divider(height: 32),
                  _buildSimpleInfo(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Status',
                    value: authStatus.isAdmin ? 'Yes' : 'No',
                  ),
                  const Divider(height: 32),
                  _buildSimpleInfo(
                    context,
                    icon: Icons.playlist_add_check,
                    label: 'Permissions',
                    value: authStatus.permissions.isEmpty
                        ? 'None'
                        : authStatus.permissions.join(', '),
                  ),
                  const SizedBox(height: 48),
                  ShadButton(
                    onPressed: () => PageManager.of(context).home(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Go to Home Screen'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShadButton.outline(
                    onPressed: () => _handleLogout(context, actions.logout),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
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

  Widget _buildSimpleInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: ShadTheme.of(context).colorScheme.mutedForeground,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: ShadTheme.of(context).textTheme.large,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    Future<void> Function() logout,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Logout'),
        description: const Text('Are you sure you want to logout?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
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
