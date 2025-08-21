import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskflow_ai/features/auth/domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create a new user document in Firestore
        try {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'name': name,
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
              });
        } catch (firestoreError) {
          // Log Firestore error but don't fail the signup
          print('Firestore error: $firestoreError');
        }
      }
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI layer
      rethrow;
    } catch (e) {
      // Handle PigeonUserDetails type casting errors
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('PigeonUserInfo') ||
          e.toString().contains('type cast')) {
        // Sign-up was successful despite the error, so don't throw
        return;
      }
      // Handle any other unexpected errors
      throw FirebaseAuthException(
        code: 'signup-failed',
        message: 'Sign up failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // If it's a new user, create a document in Firestore
      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        try {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'name': userCredential.user!.displayName,
                'email': userCredential.user!.email,
                'createdAt': FieldValue.serverTimestamp(),
              });
        } catch (firestoreError) {
          // Log Firestore error but don't fail the signup
          print('Firestore error: $firestoreError');
        }
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      // Ignore type casting errors but still allow sign-in to proceed
      if (e.toString().contains('PigeonUserInfo') ||
          e.toString().contains('type cast')) {
        // Sign-in was successful despite the error, so don't throw
        return;
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
