import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/features/auth/domain/auth_repository.dart';
import 'package:taskflow_ai/features/auth/domain/user_profile_model.dart';
import 'package:taskflow_ai/features/auth/infrastructure/firebase_auth_repository.dart';

// 1. Repository Provider (no change)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// 2. Auth State Changes Provider (no change)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// --- THIS IS THE FIX ---
// 4. User Profile Provider (Corrected Logic)
final userProfileProvider = FutureProvider<UserProfile?>((ref) {
  // Watch the AsyncValue of the auth state stream
  final authState = ref.watch(authStateChangesProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  // Get the user from the AsyncValue.data
  final user = authState.asData?.value;

  // If the user is logged in, fetch their profile. Otherwise, return null.
  if (user != null) {
    return authRepository.getUserProfile(user.uid);
  }
  return null;
});
// --- END OF FIX ---

// 3. Auth Controller Provider (no change needed here)
final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository, ref);
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
