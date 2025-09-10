import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskflow_ai/features/auth/domain/user_profile_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  // We now watch the profile in real-time instead of fetching it once.
  Stream<UserProfile?> watchUserProfile(String userId);

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> sendEmailVerification();
  Future<void> signOut();
}
