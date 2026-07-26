import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_keys.dart';
import '../di/providers.dart';

/// Persisted app-wide [ThemeMode] selection (SRS Section 10.21.2, Theme
/// Settings; Section 15.10, High Contrast Mode is a separate, later
/// concern). Defaults to following the system setting.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(StorageKeys.themeMode);
    return _fromName(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(StorageKeys.themeMode, mode.name);
  }

  ThemeMode _fromName(String? name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
