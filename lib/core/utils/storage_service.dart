import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class StorageService {
  static const _themeKey = 'pref_theme_mode';

  /// Save ThemeMode as a string: 'light' or 'dark'
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    await prefs.setString(_themeKey, value);
  }

  /// Load ThemeMode. Defaults to ThemeMode.light if not set.
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }
}
