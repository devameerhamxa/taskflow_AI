import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/features/auth/domain/auth_repository.dart';
import 'package:taskflow_ai/features/auth/infrastructure/firebase_auth_repository.dart';

// 1. Repository Provider
// This provides an instance of our FirebaseAuthRepository to the rest of the app.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// 2. Auth State Changes Provider (moved from AuthGate for global access)
// This provider listens to the authentication state stream.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// 3. Auth Controller Provider (StateNotifier)
// This handles the business logic (calling repository methods) and manages UI state.
final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository, ref);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  // ignore: unused_field
  final Ref _ref;

  // The controller's state is a simple boolean: true for loading, false for not loading.
  AuthController(this._authRepository, this._ref) : super(false);

  // Method to get the current user
  User? get currentUser => _authRepository.currentUser;

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required Function(String) onError,
  }) async {
    state = true; // Set loading state
    try {
      await _authRepository.signUpWithEmailAndPassword(email: email, password: password, name: name);
      await _authRepository.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'An unknown error occurred.');
    } finally {
      state = false; // Reset loading state
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password, Function(String) onError) async {
    state = true;
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'An unknown error occurred.');
    } finally {
      state = false;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle(Function(String) onError) async {
    state = true;
    try {
      await _authRepository.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'An unknown error occurred.');
    } finally {
      state = false;
    }
  }
  
  // Send email verification
  Future<void> sendEmailVerification(Function(String) onError) async {
    state = true;
    try {
      await _authRepository.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'An unknown error occurred.');
    } finally {
      state = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = true;
    await _authRepository.signOut();
    state = false;
  }
}
