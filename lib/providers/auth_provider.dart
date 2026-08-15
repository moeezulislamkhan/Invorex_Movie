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

  Future<void> setOnboardingComplete() => _storage.setOnboardingComplete(true);

  Future<void> load() async {
    final user = _auth.currentUser;

    if (user != null) {
      _loggedIn = true;
      _email = user.email ?? '';

      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data();

          _name = data?['name'] ?? user.displayName ?? 'Movie Lover';
        } else {
          _name = user.displayName ?? 'Movie Lover';
        }
      } catch (_) {
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

    // 4. Firestore profile background mein save karo.
    // Signup ko Firestore ke response ka wait nahi karna.
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

 Future<bool> login({
  required String email,
  required String password,
}) async {
  if (email.trim().isEmpty || password.isEmpty) {
    return false;
  }

  try {
    // Firebase Authentication
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      return false;
    }

    // Firebase Auth successful
    _email = user.email ?? email.trim();
    _name = user.displayName ?? 'Movie Lover';
    _loggedIn = true;

    // Local storage
    await _storage.saveUser(
      name: _name,
      email: _email,
    );

    await _storage.setLoggedIn(true);

    notifyListeners();

    // Firestore ko background mein load karo
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

    // Firebase Authentication mein name update
    await user.updateDisplayName(cleanName);

    // Firestore mein user ka name update
    await _firestore.collection('users').doc(user.uid).set(
      {
        'name': cleanName,
        'email': user.email ?? _email,
      },
      SetOptions(merge: true),
    );

    // Local state update
    _name = cleanName;

    // Local storage update
    await _storage.saveUser(
      name: _name,
      email: _email,
    );

    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();

    _loggedIn = false;
    _name = 'Guest';
    _email = '';

    await _storage.clearSession();

    notifyListeners();
  }
}
