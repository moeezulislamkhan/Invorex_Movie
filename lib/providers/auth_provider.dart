import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage);

  final LocalStorageService _storage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  bool _loggedIn = false;
  String _name = 'Guest';
  String _email = '';

  bool get initialized => _initialized;
  bool get loggedIn => _loggedIn;
  String get name => _name;
  String get email => _email;

  Future<bool> onboardingComplete() => _storage.onboardingComplete;

  Future<void> setOnboardingComplete() async {
    await _storage.setOnboardingComplete(true);
  }

  // =========================
  // LOAD USER
  // =========================

  Future<void> load() async {
    final user = _auth.currentUser;

    if (user != null) {
      _loggedIn = true;
      _email = user.email ?? '';

      try {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();

          _name = data?['name'] ??
              user.displayName ??
              'Movie Lover';
        } else {
          _name = user.displayName ?? 'Movie Lover';
        }
      } catch (e) {
        debugPrint('Load profile error: $e');
        _name = user.displayName ?? 'Movie Lover';
      }
    } else {
      _loggedIn = false;
      _name = 'Guest';
      _email = '';
    }

    _initialized = true;
    notifyListeners();
  }

  // =========================
  // SIGN UP
  // =========================

  Future<void> signUp({
  required String name,
  required String email,
  required String password,
}) async {
  final cleanName = name.trim();
  final cleanEmail = email.trim();

  try {
    // 1. Firebase Authentication account create
    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed.');
    }

    // 2. Update Firebase Auth display name
    try {
      await user.updateDisplayName(cleanName);
    } catch (e) {
      debugPrint('Display name update error: $e');
    }

    // 3. Update local state immediately
    _name = cleanName;
    _email = cleanEmail;
    _loggedIn = true;

    await _storage.saveUser(
      name: _name,
      email: _email,
    );

    await _storage.setLoggedIn(true);

    notifyListeners();

    // 4. Firestore profile background mein save karo
    _saveFirestoreProfile(
      uid: user.uid,
      name: cleanName,
      email: cleanEmail,
    );
  } on FirebaseAuthException catch (e) {
    debugPrint('Firebase Signup Error: ${e.code}');
    debugPrint('Firebase Signup Message: ${e.message}');

    throw Exception(e.message ?? 'Account creation failed.');
  } catch (e) {
    debugPrint('Signup Error: $e');
    rethrow;
  }
}
Future<void> _saveFirestoreProfile({
  required String uid,
  required String name,
  required String email,
}) async {
  try {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Firestore profile saved successfully.');
  } catch (e) {
    debugPrint('Firestore profile save error: $e');
  }
}

  // =========================
  // LOGIN
  // =========================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return false;
    }

    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return false;
      }

      _email = user.email ?? email.trim();
      _name = user.displayName ?? 'Movie Lover';
      _loggedIn = true;

      await _storage.saveUser(
        name: _name,
        email: _email,
      );

      await _storage.setLoggedIn(true);

      notifyListeners();

      // Firestore background mein load hoga
      _loadFirestoreProfile(user.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login Error: ${e.code}');
      debugPrint('Firebase Login Message: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  // =========================
  // FIRESTORE PROFILE
  // =========================

  Future<void> _loadFirestoreProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        _name = data?['name'] ??
            _auth.currentUser?.displayName ??
            'Movie Lover';

        await _storage.saveUser(
          name: _name,
          email: _email,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firestore profile error: $e');
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================

 Future<void> updateProfile({
  required String name,
}) async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception('User is not logged in.');
  }

  final cleanName = name.trim();

  if (cleanName.isEmpty) {
    throw Exception('Name cannot be empty.');
  }

  // UI immediately update
  _name = cleanName;
  notifyListeners();

  // Local storage immediately update
  await _storage.saveUser(
    name: cleanName,
    email: _email,
  );

  // Firebase background update
  _updateFirebaseProfile(
    user: user,
    name: cleanName,
  );
}

 Future<void> _updateFirebaseProfile({
  required User user,
  required String name,
}) async {
  try {
    await Future.wait([
      user.updateDisplayName(name),
      _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': name,
          'email': user.email ?? _email,
        },
        SetOptions(merge: true),
      ),
    ]);

    debugPrint('Profile updated on Firebase.');
  } catch (e) {
    debugPrint('Firebase profile update error: $e');
  }
}

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await _auth.signOut();

    _loggedIn = false;
    _name = 'Guest';
    _email = '';

    await _storage.clearSession();

    notifyListeners();
  }
}