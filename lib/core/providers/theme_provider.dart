import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provider for ThemeNotifier.
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _themePreferenceKey = 'theme_preference';
  final SharedPreferences _prefs;

  // Constructor for ThemeNotifier.
  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  // Load theme using the provided instance.
  void _loadTheme() {
    final themeIndex = _prefs.getInt(_themePreferenceKey) ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  // Set theme using the provided instance.
  Future<void> setTheme(ThemeMode themeMode) async {
    if (state != themeMode) {
      state = themeMode;
      await _prefs.setInt(_themePreferenceKey, themeMode.index);
    }
  }
}
