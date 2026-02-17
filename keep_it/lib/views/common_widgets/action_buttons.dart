import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Theme toggle button widget.
///
/// Displays a button to toggle between light and dark themes.
/// Uses GetThemeMode builder to decouple from direct provider access.
class OnDarkMode extends StatelessWidget {
  const OnDarkMode({super.key});

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
