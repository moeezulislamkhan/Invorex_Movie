import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  final LocalStorageService _storage;

  bool _isDark = true;
  bool get isDark => _isDark;

  Future<void> load() async {
    _isDark = await _storage.isDarkTheme;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    await _storage.setDarkTheme(_isDark);
    notifyListeners();
  }
}
