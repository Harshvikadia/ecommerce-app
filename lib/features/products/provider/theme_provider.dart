import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'is_dark';

  final SharedPreferences _prefs;
  bool _isDark;

  ThemeProvider(this._prefs) : _isDark = _prefs.getBool(_key) ?? false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners(); // pehle UI badlo, phir save karo
    await _prefs.setBool(_key, value);
  }
}