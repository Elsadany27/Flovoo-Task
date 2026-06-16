import 'package:flutter/material.dart';

import '../constants/hive_constants.dart';
import 'hive_service.dart';

class ThemeService extends ChangeNotifier {
  ThemeService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final stored = _hiveService.appBox.get(HiveConstants.themeModeKey);
    if (stored is String) {
      _themeMode = _parseThemeMode(stored);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _hiveService.appBox.put(HiveConstants.themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> toggleTheme() {
    final next =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setThemeMode(next);
  }

  ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }
}
