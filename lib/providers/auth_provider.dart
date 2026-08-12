import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage);

  final LocalStorageService _storage;

  bool _initialized = false;
  bool _loggedIn = false;
  String _name = 'Guest';
  String _email = '';

  bool get initialized => _initialized;
  bool get loggedIn => _loggedIn;
  String get name => _name;
  String get email => _email;

  Future<bool> onboardingComplete() => _storage.onboardingComplete;

  Future<void> setOnboardingComplete() => _storage.setOnboardingComplete(true);

  Future<void> load() async {
    _loggedIn = await _storage.loggedIn;
    _name = await _storage.userName ?? 'Guest';
    _email = await _storage.userEmail ?? '';
    _initialized = true;
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
  }) async {
    _name = name.trim();
    _email = email.trim();
    _loggedIn = true;
    await _storage.saveUser(name: _name, email: _email);
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    final savedEmail = await _storage.userEmail;
    if (savedEmail == null) return false;
    if (savedEmail.trim().toLowerCase() != email.trim().toLowerCase()) {
      return false;
    }

    _email = savedEmail;
    _name = await _storage.userName ?? 'Movie Lover';
    _loggedIn = true;
    await _storage.setLoggedIn(true);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _loggedIn = false;
    await _storage.clearSession();
    notifyListeners();
  }
}
