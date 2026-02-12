import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import 'server_config_dialog.dart';

/// View displayed when user is logged in.
class LoggedInView extends ConsumerWidget {
  const LoggedInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider).value;
    final serverPrefs = ref.watch(serverPreferencesProvider);

    if (authState == null || !authState.isAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    final loginTimeStr = authState.loginTimestamp != null
        ? '${authState.loginTimestamp!.toString().substring(0, 19)}'
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
                value: authState.currentUser?.username ?? 'Unknown',
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
                value: serverPrefs.authUrl,
                action: IconButton(
                  icon: const Icon(Icons.settings, size: 18),
                  onPressed: () => _showServerConfigDialog(context),
                  tooltip: 'Edit Server URLs',
                ),
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
                onPressed: () => _handleLogout(context, ref),
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
          if (action != null) action,
        ],
      ),
    );
  }

  void _showServerConfigDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const ServerConfigDialog(),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
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
              ref.read(authStateProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
