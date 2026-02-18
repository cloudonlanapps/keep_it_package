import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppPreferences {
  const AppPreferences({
    required this.themeMode,
    this.pageSize = 12,
  });
  final ThemeMode themeMode;
  final int pageSize;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    int? pageSize,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  String toString() =>
      'AppPreferences(themeMode: $themeMode, pageSize: $pageSize)';

  @override
  bool operator ==(covariant AppPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode && other.pageSize == pageSize;
  }

  @override
  int get hashCode => themeMode.hashCode ^ pageSize.hashCode;
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
