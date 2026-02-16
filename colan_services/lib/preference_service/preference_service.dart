// Preference Service - App preferences management
//
// This service provides app-level preferences like theme mode, icon color, etc.

// Export builders
export 'builders/get_theme_mode.dart' show GetThemeMode, ThemeModeActions;

// Export providers (includes models and notifier)
export 'providers/app_preference_provider.dart'
    show AppPreferenceNotifier, AppPreferences, appPreferenceProvider;
