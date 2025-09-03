import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. A new provider that will expose the SharedPreferences instance.
// We throw an error because it MUST be overridden in main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// 2. The theme provider now depends on the SharedPreferences provider.
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _themePreferenceKey = 'theme_preference';
  final SharedPreferences _prefs;

  // 3. The constructor now accepts the SharedPreferences instance.
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
