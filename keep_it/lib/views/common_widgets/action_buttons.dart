import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../page_manager.dart';

/// Theme toggle button widget.
///
/// Displays a button to toggle between light and dark themes.
/// Uses GetThemeMode builder to decouple from direct provider access.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetThemeMode(
      builder: (themeMode, actions) {
        return ShadButton.ghost(
          onPressed: actions.toggleTheme,
          child: switch (themeMode) {
            ThemeMode.system => throw UnimplementedError(),
            ThemeMode.light => clIcons.lightMode.iconFormatted(),
            ThemeMode.dark => clIcons.darkMode.iconFormatted(),
          },
        );
      },
    );
  }
}

class UserAccountButton extends StatelessWidget {
  const UserAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      onPressed: () => PageManager.of(context).openAuthenticator(),
      child: const Icon(LucideIcons.user, size: 25),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      onPressed: () => PageManager.of(context).openSettings(),
      child: const Icon(LucideIcons.settings, size: 25),
    );
  }
}

class ReloadButton extends StatelessWidget {
  const ReloadButton({
    required this.onReload,
    super.key,
  });

  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    if (ColanPlatformSupport.isMobilePlatform) {
      return const SizedBox.shrink();
    }
    return CLRefreshButton(
      onRefresh: onReload,
    );
  }
}
