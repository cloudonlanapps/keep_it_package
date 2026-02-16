import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_preference_provider.dart';

/// Immutable class encapsulating theme mode actions.
@immutable
class ThemeModeActions {
  const ThemeModeActions({
    required this.setThemeMode,
    required this.toggleTheme,
  });

  final void Function(ThemeMode) setThemeMode;
  final void Function() toggleTheme;
}

/// Builder widget that watches theme mode and exposes theme actions.
///
/// This builder decouples views from direct provider access by providing
/// theme mode data and actions through callback parameters.
///
/// Example usage:
/// ```dart
/// GetThemeMode(
///   builder: (themeMode, actions) {
///     return ShadButton.ghost(
///       onPressed: actions.toggleTheme,
///       child: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
///     );
///   },
/// )
/// ```
class GetThemeMode extends ConsumerWidget {
  const GetThemeMode({
    required this.builder,
    super.key,
  });

  final Widget Function(ThemeMode, ThemeModeActions) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(appPreferenceProvider.select((e) => e.themeMode));
    final actions = ThemeModeActions(
      setThemeMode: (mode) =>
          ref.read(appPreferenceProvider.notifier).themeMode = mode,
      toggleTheme: () {
        final currentMode =
            ref.read(appPreferenceProvider.select((e) => e.themeMode));
        final newMode =
            currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        ref.read(appPreferenceProvider.notifier).themeMode = newMode;
      },
    );
    return builder(themeMode, actions);
  }
}
