import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeManager extends ChangeNotifier {
  static const String _boxName = 'theme_settings';
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initialize() async {
    final box = await Hive.openBox(_boxName);
    final savedTheme = box.get(_themeKey, defaultValue: 'dark');
    _themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
