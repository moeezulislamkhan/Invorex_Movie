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
  String? _profileImagePath;

  bool get initialized => _initialized;
  bool get loggedIn => _loggedIn;
  String get name => _name;
  String get email => _email;
  String? get profileImagePath => _profileImagePath;

  // ============================================================
  // ONBOARDING
  // ============================================================

  Future<bool> onboardingComplete() {
    return _storage.onboardingComplete;
  }

  Future<void> setOnboardingComplete() async {
    await _storage.setOnboardingComplete(true);
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> load() async {
    final savedImagePath = await _storage.profileImagePath;

    // Empty string ko null treat karna hai
    _profileImagePath =
        savedImagePath != null && savedImagePath.isNotEmpty
            ? savedImagePath
            : null;

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

          // Firestore email agar available ho
          final firestoreEmail = data?['email'];

          if (firestoreEmail != null &&
              firestoreEmail.toString().isNotEmpty) {
            _email = firestoreEmail.toString();
          }
        } else {
          _name = user.displayName ?? 'Movie Lover';
        }
      } catch (e) {
        debugPrint(
          'Load profile error: $e',
        );

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

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Account creation failed.',
        );
      }

      // Firebase display name
      try {
        await user.updateDisplayName(cleanName);
      } catch (e) {
        debugPrint(
          'Display name update error: $e',
        );
      }

      // Local state
      _name = cleanName;
      _email = cleanEmail;
      _loggedIn = true;

      await _storage.saveUser(
        name: _name,
        email: _email,
      );

      await _storage.setLoggedIn(true);

      notifyListeners();

      // Firestore
      await _saveFirestoreProfile(
        uid: user.uid,
        name: cleanName,
        email: cleanEmail,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Signup Error: ${e.code}',
      );

      debugPrint(
        'Firebase Signup Message: ${e.message}',
      );

      switch (e.code) {
        case 'email-already-in-use':
          throw Exception(
            'An account already exists with this email.',
          );

        case 'invalid-email':
          throw Exception(
            'Please enter a valid email address.',
          );

        case 'weak-password':
          throw Exception(
            'Password is too weak.',
          );

        default:
          throw Exception(
            e.message ??
                'Account creation failed.',
          );
      }
    } catch (e) {
      debugPrint(
        'Signup Error: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // SAVE FIRESTORE PROFILE
  // ============================================================

  Future<void> _saveFirestoreProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(
        {
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      debugPrint(
        'Firestore profile saved successfully.',
      );
    } catch (e) {
      debugPrint(
        'Firestore profile save error: $e',
      );
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================
// ============================================================
// LOGIN
// ============================================================

Future<bool> login({
  required String email,
  required String password,
}) async {
  final cleanEmail = email.trim();

  if (cleanEmail.isEmpty || password.isEmpty) {
    return false;
  }

  try {
    // ========================================================
    // FIREBASE LOGIN
    // ========================================================

    final credential =
        await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      return false;
    }

    // ========================================================
    // UPDATE STATE IMMEDIATELY
    // ========================================================

    _email = user.email ?? cleanEmail;
    _name = user.displayName ?? 'Movie Lover';
    _loggedIn = true;

    notifyListeners();

    // ========================================================
    // SAVE LOCAL SESSION
    // ========================================================

    await _storage.saveUser(
      name: _name,
      email: _email,
    );

    await _storage.setLoggedIn(true);

    // ========================================================
    // FIRESTORE PROFILE BACKGROUND MEIN LOAD HOGA
    // ========================================================
    //
    // IMPORTANT:
    // Yahan await nahi lagana.
    // Is se login screen Firestore ka wait nahi karegi.
    //

    _loadFirestoreProfile(user.uid);

    // ========================================================
    // LOGIN SUCCESS
    // ========================================================

    return true;
  } on FirebaseAuthException catch (e) {
    debugPrint(
      'Firebase Login Error: ${e.code}',
    );

    debugPrint(
      'Firebase Login Message: ${e.message}',
    );

    return false;
  } catch (e) {
    debugPrint(
      'Login Error: $e',
    );

    return false;
  }
}
  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> resetPassword({
    required String email,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw Exception(
        'Please enter your email address.',
      );
    }

    if (!cleanEmail.contains('@')) {
      throw Exception(
        'Please enter a valid email address.',
      );
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: cleanEmail,
      );

      debugPrint(
        'Password reset email sent to: $cleanEmail',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Password Reset Error: ${e.code}',
      );

      debugPrint(
        'Firebase Password Reset Message: ${e.message}',
      );

      switch (e.code) {
        case 'invalid-email':
          throw Exception(
            'Please enter a valid email address.',
          );

        case 'user-not-found':
          throw Exception(
            'No account was found with this email.',
          );

        case 'too-many-requests':
          throw Exception(
            'Too many requests. Please try again later.',
          );

        case 'network-request-failed':
          throw Exception(
            'Network error. Please check your internet connection.',
          );

        default:
          throw Exception(
            e.message ??
                'Unable to send password reset email.',
          );
      }
    } catch (e) {
      debugPrint(
        'Password Reset Error: $e',
      );

      throw Exception(
        'Unable to send password reset email.',
      );
    }
  }

  // ============================================================
  // LOAD FIRESTORE PROFILE
  // ============================================================

  Future<void> _loadFirestoreProfile(
    String uid,
  ) async {
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

        final firestoreEmail = data?['email'];

        if (firestoreEmail != null &&
            firestoreEmail.toString().isNotEmpty) {
          _email = firestoreEmail.toString();
        }

        await _storage.saveUser(
          name: _name,
          email: _email,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint(
        'Firestore profile error: $e',
      );
    }
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Future<void> setProfileImage(
    String? path,
  ) async {
    _profileImagePath =
        path != null && path.isNotEmpty
            ? path
            : null;

    // Storage mein empty string save karenge jab image remove ho.
    await _storage.saveProfileImagePath(
      _profileImagePath ?? '',
    );

    notifyListeners();
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================
// ============================================================
// UPDATE PROFILE - FAST & SAFE
// ============================================================

Future<void> updateProfile({
  required String name,
  String? email,
  String? newPassword,
}) async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception('User is not logged in.');
  }

  final cleanName = name.trim();
  final cleanEmail = email?.trim() ?? _email;
  final cleanPassword = newPassword?.trim() ?? '';

  // ==========================================================
  // VALIDATION
  // ==========================================================

  if (cleanName.isEmpty) {
    throw Exception('Name cannot be empty.');
  }

  if (cleanEmail.isEmpty) {
    throw Exception('Email cannot be empty.');
  }

  if (!cleanEmail.contains('@')) {
    throw Exception('Please enter a valid email address.');
  }

  if (cleanPassword.isNotEmpty && cleanPassword.length < 6) {
    throw Exception(
      'New password must be at least 6 characters.',
    );
  }

  final oldName = user.displayName ?? '';
  final oldEmail = user.email ?? '';

  final nameChanged = cleanName != oldName;
  final emailChanged = cleanEmail != oldEmail;
  final passwordChanged = cleanPassword.isNotEmpty;

  // Agar kuch bhi change nahi hua
  if (!nameChanged && !emailChanged && !passwordChanged) {
    return;
  }

  try {
    // ========================================================
    // NAME
    // ========================================================

    if (nameChanged) {
      try {
        await user.updateDisplayName(cleanName);
      } on FirebaseAuthException catch (e) {
        throw Exception(
          e.message ?? 'Unable to update name.',
        );
      }

      _name = cleanName;
    }

    // ========================================================
    // EMAIL
    // ========================================================

    if (emailChanged) {
      try {
        await user.verifyBeforeUpdateEmail(
          cleanEmail,
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'requires-recent-login':
            throw Exception(
              'For security, please log in again before changing your email.',
            );

          case 'email-already-in-use':
            throw Exception(
              'This email is already being used by another account.',
            );

          case 'invalid-email':
            throw Exception(
              'Please enter a valid email address.',
            );

          default:
            throw Exception(
              e.message ?? 'Unable to update email.',
            );
        }
      }
    }

    // ========================================================
    // PASSWORD
    // ========================================================

    if (passwordChanged) {
      try {
        await user.updatePassword(
          cleanPassword,
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'requires-recent-login':
            throw Exception(
              'For security, please log in again before changing your password.',
            );

          case 'weak-password':
            throw Exception(
              'New password is too weak.',
            );

          default:
            throw Exception(
              e.message ?? 'Unable to update password.',
            );
        }
      }
    }

    // ========================================================
    // LOCAL STATE
    // ========================================================

    _name = cleanName;

    // Agar email same hai to normal update.
    // Agar email change hui hai to verification ke baad
    // Firebase current email update karega.
    if (!emailChanged) {
      _email = cleanEmail;
    }

    // ========================================================
    // UPDATE UI IMMEDIATELY
    // ========================================================

    notifyListeners();

    // ========================================================
    // LOCAL STORAGE
    // ========================================================

    try {
      await _storage.saveUser(
        name: _name,
        email: _email,
      );
    } catch (e) {
      debugPrint(
        'Local storage update error: $e',
      );
    }

    // ========================================================
    // FIRESTORE SYNC
    // ========================================================
    //
    // Firestore ko blocking operation nahi banana.
    // UI already update ho chuki hai.
    //

    _syncProfileToFirestore(
      uid: user.uid,
      name: _name,
      email: cleanEmail,
    );

    debugPrint(
      'Profile updated successfully.',
    );
  } on FirebaseAuthException catch (e) {
    debugPrint(
      'Firebase Profile Update Error: ${e.code}',
    );

    throw Exception(
      e.message ?? 'Unable to update profile.',
    );
  } catch (e) {
    debugPrint(
      'Profile Update Error: $e',
    );

    rethrow;
  }
}

// ============================================================
// FIRESTORE PROFILE SYNC
// ============================================================

Future<void> _syncProfileToFirestore({
  required String uid,
  required String name,
  required String email,
}) async {
  try {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      {
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );

    debugPrint(
      'Firestore profile synced successfully.',
    );
  } catch (e) {
    // Firestore error UI ko block nahi karega.
    debugPrint(
      'Firestore profile sync error: $e',
    );
  }

}  

// ============================================================
// DELETE ACCOUNT
// ============================================================

Future<void> deleteAccount() async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception(
      'User is not logged in.',
    );
  }

  try {
    // ========================================================
    // 1. DELETE FIRESTORE PROFILE
    // ========================================================

    await _firestore
        .collection('users')
        .doc(user.uid)
        .delete();

    // ========================================================
    // 2. DELETE FIREBASE AUTH ACCOUNT
    // ========================================================

    await user.delete();

    // ========================================================
    // 3. CLEAR LOCAL STATE
    // ========================================================

    _loggedIn = false;
    _name = 'Guest';
    _email = '';
    _profileImagePath = null;

    // ========================================================
    // 4. CLEAR LOCAL STORAGE
    // ========================================================

    await _storage.clearSession();

    // ========================================================
    // 5. UPDATE UI
    // ========================================================

    notifyListeners();

    debugPrint(
      'Account deleted successfully.',
    );
  } on FirebaseAuthException catch (e) {
    debugPrint(
      'Delete Account Error: ${e.code}',
    );

    switch (e.code) {
      case 'requires-recent-login':
        throw Exception(
          'For security, please log in again before deleting your account.',
        );

      case 'network-request-failed':
        throw Exception(
          'Network error. Please check your internet connection.',
        );

      default:
        throw Exception(
          e.message ??
              'Unable to delete account.',
        );
    }
  } catch (e) {
    debugPrint(
      'Delete Account Error: $e',
    );

    rethrow;
  }
}


// ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();

    _loggedIn = false;
    _name = 'Guest';
    _email = '';
    _profileImagePath = null;

    await _storage.clearSession();

    notifyListeners();
  }
}