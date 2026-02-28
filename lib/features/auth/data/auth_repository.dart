import 'package:firebase_auth/firebase_auth.dart';

/// Repository for Firebase Authentication operations.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// Stream of auth state changes.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Current user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
