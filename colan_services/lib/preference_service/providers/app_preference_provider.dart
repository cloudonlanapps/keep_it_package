import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppPreferences {
  const AppPreferences({
    required this.themeMode,
  });
  final ThemeMode themeMode;

  AppPreferences copyWith({
    ThemeMode? themeMode,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() => 'AppPreferences(themeMode: $themeMode)';

  @override
  bool operator ==(covariant AppPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}

class AppPreferenceNotifier extends StateNotifier<AppPreferences> {
  AppPreferenceNotifier()
      : super(const AppPreferences(themeMode: ThemeMode.light));

  set themeMode(ThemeMode value) => state = state.copyWith(themeMode: value);
  ThemeMode get themeMode => state.themeMode;
}

final appPreferenceProvider =
    StateNotifierProvider<AppPreferenceNotifier, AppPreferences>((ref) {
  return AppPreferenceNotifier();
});
