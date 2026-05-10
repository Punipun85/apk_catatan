import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();
  static const String _darkModeKey = 'dark_mode';

  Future<bool> getDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
