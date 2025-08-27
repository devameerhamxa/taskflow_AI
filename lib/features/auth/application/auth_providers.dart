import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/features/auth/domain/auth_repository.dart';
import 'package:taskflow_ai/features/auth/domain/user_profile_model.dart';
import 'package:taskflow_ai/features/auth/infrastructure/firebase_auth_repository.dart';

// 1. Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// 2. Auth State Changes Provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// 3. Auth Controller Provider (StateNotifier)
final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository, ref);
});

// 4. User Profile Provider
// Fetches the profile of the currently logged-in user.
final userProfileProvider = FutureProvider<UserProfile?>((ref) {
  // Watching authStateChangesProvider ensures this provider re-runs on login/logout
  ref.watch(authStateChangesProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getUserProfile();
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController(this._authRepository, this._ref) : super(false);

  User? get currentUser => _authRepository.currentUser;

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required Function(String) onError,
  }) async {
    state = true;
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      await _authRepository.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'An unknown error occurred.');
    } finally {
      state = false;
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    Function(String) onError,
  ) async {
    state = true;
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'An unknown error occurred.');
    } finally {
      state = false;
    }
  }

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

  Future<void> signOut() async {
    state = true;
    await _authRepository.signOut();
    state = false;
  }
}
