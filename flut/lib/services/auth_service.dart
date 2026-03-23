import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Service
/// 
/// Handles user sign-up, sign-in, and session management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  void _validateCredentials(String email, String password) {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required.');
    }
    if (password.isEmpty) {
      throw Exception('Password is required.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  /// 
  /// Returns User if successful, throws FirebaseAuthException on error
  Future<User?> signUp(String email, String password) async {
    try {
      _validateCredentials(email, password);
      final UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: _normalizeEmail(email),
        password: password,
      );
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }
      await _ensureUserProfile(userCredential.user);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for this email.');
      } else {
        throw Exception('Sign up failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during sign up: $e');
    }
  }

  /// Sign in with email and password
  /// 
  /// Returns User if successful, throws FirebaseAuthException on error
  Future<User?> signIn(String email, String password) async {
    try {
      _validateCredentials(email, password);
      final UserCredential userCredential = 
          await _auth.signInWithEmailAndPassword(
        email: _normalizeEmail(email),
        password: password,
      );

      final signedInUser = userCredential.user;
      if (signedInUser != null && !signedInUser.emailVerified) {
        await _auth.signOut();
        throw Exception('Please verify your email before logging in.');
      }

      await _ensureUserProfile(userCredential.user);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'user-not-found') {
        throw Exception('No user found for this email.');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Sign in failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during sign in: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      if (normalizedEmail.isEmpty) {
        throw Exception('Email is required.');
      }
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user found.');
    }
    if (user.emailVerified) {
      return;
    }
    await user.sendEmailVerification();
  }

  Future<bool> isCurrentUserEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> _ensureUserProfile(User? user) async {
    if (user == null) return;

    final docRef = _firestore.collection('user_profiles').doc(user.uid);
    final existing = await docRef.get();
    final now = FieldValue.serverTimestamp();

    final data = {
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'avatarUrl': user.photoURL ?? '',
      'course': 'Cloud Computing',
      'coursesEnrolled': 3,
      'learningStreak': 7,
      'updatedAt': now,
      if (!existing.exists) 'createdAt': now,
    };

    await docRef.set(data, SetOptions(merge: true));
  }
}
