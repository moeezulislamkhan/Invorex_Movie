import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const _onboardingKey = 'onboarding_complete';
  static const _loggedInKey = 'logged_in';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _watchlistKey = 'watchlist_keys';
  static const _themeDarkKey = 'theme_dark';

  Future<bool> get onboardingComplete async =>
      await _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_onboardingKey, value);

  Future<bool> get loggedIn async => await _prefs.getBool(_loggedInKey) ?? false;

  Future<void> setLoggedIn(bool value) => _prefs.setBool(_loggedInKey, value);

  Future<String?> get userName => _prefs.getString(_userNameKey);

  Future<String?> get userEmail => _prefs.getString(_userEmailKey);

  Future<void> saveUser({
    required String name,
    required String email,
  }) async {
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setBool(_loggedInKey, true);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_loggedInKey, false);
  }

  Future<List<String>> get watchlistKeys async =>
      await _prefs.getStringList(_watchlistKey) ?? <String>[];

  Future<void> saveWatchlistKeys(List<String> keys) =>
      _prefs.setStringList(_watchlistKey, keys);

  Future<String?> getCustomString(String key) => _prefs.getString(key);

  Future<void> setCustomString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> removeCustomString(String key) => _prefs.remove(key);

  Future<bool> get isDarkTheme async => await _prefs.getBool(_themeDarkKey) ?? true;

  Future<void> setDarkTheme(bool value) => _prefs.setBool(_themeDarkKey, value);
}
