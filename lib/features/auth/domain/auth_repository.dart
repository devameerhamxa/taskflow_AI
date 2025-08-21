import 'package:firebase_auth/firebase_auth.dart';

// This is the contract that any authentication repository must follow.
// It's great for testing and swapping out implementations later.
abstract class AuthRepository {
  // A stream to listen for authentication state changes.
  Stream<User?> get authStateChanges;

  // Get the current user, if any.
  User? get currentUser;

  // Sign up with email and password.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name, // Added name for user profile
  });

  // Sign in with email and password.
  Future<void> signInWithEmailAndPassword(String email, String password);

  // Sign in with Google.
  Future<void> signInWithGoogle();

  // Send an email verification link to the current user.
  Future<void> sendEmailVerification();

  // Sign out the current user.
  Future<void> signOut();
}
