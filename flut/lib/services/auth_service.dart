import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Service
/// 
/// Handles user sign-up, sign-in, and session management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  /// 
  /// Returns User if successful, throws FirebaseAuthException on error
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      final UserCredential userCredential = 
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserProfile(userCredential.user);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'user-not-found') {
        throw Exception('No user found for this email.');
      } else if (e.code == 'wrong-password') {
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
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
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
