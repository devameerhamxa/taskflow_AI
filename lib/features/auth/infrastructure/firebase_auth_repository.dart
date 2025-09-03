import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskflow_ai/features/auth/domain/auth_repository.dart';
import 'package:taskflow_ai/features/auth/domain/user_profile_model.dart';

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
  Stream<UserProfile?> watchUserProfile(String userId) {
    log('[AuthRepo] ✅ Setting up user profile stream for ID: $userId');

    final docRef = _firestore.collection('users').doc(userId);

    return docRef.snapshots().asyncMap((snapshot) async {
      try {
        if (snapshot.exists && snapshot.data() != null) {
          log('[AuthRepo] ✅ User profile data received from stream');
          return UserProfile.fromSnapshotGeneric(snapshot);
        } else {
          log('[AuthRepo] ⚠️ Profile document missing for ID: $userId');
          log(
            '[AuthRepo] 📊 Snapshot exists: ${snapshot.exists}, Data: ${snapshot.data()}',
          );

          // Try to create the missing profile if current user matches
          if (_firebaseAuth.currentUser?.uid == userId) {
            log(
              '[AuthRepo] 🛠️ Attempting to create missing profile for current user',
            );
            final profile = await ensureUserProfileExists();
            return profile;
          } else {
            log(
              '[AuthRepo] ⚠️ Cannot create profile - user ID mismatch or no current user',
            );
            return null;
          }
        }
      } catch (e, stackTrace) {
        log(
          '[AuthRepo] ❌ Error in profile stream',
          error: e,
          stackTrace: stackTrace,
        );
        return null;
      }
    });
  }

  // Add this method to check if user profile exists and create if needed
  Future<UserProfile?> ensureUserProfileExists() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      log('[AuthRepo] ❌ Cannot ensure profile - no current user');
      return null;
    }

    try {
      log(
        '[AuthRepo] 🔍 Checking if profile exists for user: ${currentUser.uid}',
      );
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        log('[AuthRepo] ✅ Profile already exists');
        return UserProfile.fromSnapshotGeneric(doc);
      } else {
        log(
          '[AuthRepo] 🛠️ Profile missing. Creating now for user: ${currentUser.uid}',
        );
        log(
          '[AuthRepo] 📋 User info - Name: ${currentUser.displayName}, Email: ${currentUser.email}',
        );

        final userProfile = UserProfile(
          id: currentUser.uid,
          name:
              currentUser.displayName ??
              currentUser.email?.split('@').first ??
              'User',
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
        );

        log('[AuthRepo] 💾 Attempting to create profile document...');
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(userProfile.toJsonWithDateTime());

        log('[AuthRepo] ✅ Profile document created successfully');

        // Verify creation
        final verifyDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (verifyDoc.exists) {
          log('[AuthRepo] ✅ Profile creation verified');
          return UserProfile.fromSnapshotGeneric(verifyDoc);
        } else {
          log('[AuthRepo] ❌ Profile creation verification FAILED');
          return null;
        }
      }
    } catch (e, stackTrace) {
      log(
        '[AuthRepo] ❌ Error ensuring profile exists',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      log('[AuthRepo] 🚀 Starting email signup process for: $email');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      log(
        '[AuthRepo] ✅ Firebase Auth user created. UID: ${userCredential.user?.uid}',
      );
      log(
        '[AuthRepo] 📋 User details - Email: ${userCredential.user?.email}, EmailVerified: ${userCredential.user?.emailVerified}',
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Update the display name first
        await user.updateDisplayName(name);
        await user.reload();

        final userProfile = UserProfile(
          id: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        log('[AuthRepo] 💾 Creating Firestore profile document...');
        log('[AuthRepo] 📄 Profile data: ${userProfile.toString()}');

        final docRef = _firestore.collection('users').doc(user.uid);
        await docRef.set(userProfile.toJsonWithDateTime());

        log('[AuthRepo] ✅ Firestore document set operation completed');

        // Immediate verification
        final verifyDoc = await docRef.get();
        if (verifyDoc.exists) {
          log('[AuthRepo] ✅ Document creation verified immediately');
          log('[AuthRepo] 📄 Verified data: ${verifyDoc.data()}');
        } else {
          log(
            '[AuthRepo] ❌ Document creation verification FAILED - document does not exist',
          );
          throw Exception('Failed to create user profile document');
        }
      } else {
        log('[AuthRepo] ❌ User credential is null after signup');
        throw Exception('User credential is null after signup');
      }
    } on FirebaseAuthException catch (e) {
      log(
        '[AuthRepo] ❌ FIREBASE AUTH ERROR during Email Sign Up: ${e.code} - ${e.message}',
        error: e,
      );
      rethrow;
    } on FirebaseException catch (e) {
      log(
        '[AuthRepo] ❌ FIRESTORE ERROR during Email Sign Up: ${e.code} - ${e.message}',
        error: e,
      );
      log(
        '[AuthRepo] 🔍 Firestore error details - Plugin: ${e.plugin}, StackTrace: ${e.stackTrace}',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        '[AuthRepo] ❌ UNKNOWN ERROR during Email Sign Up',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      log('[AuthRepo] 🚀 Starting Google Sign-In process...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log('[AuthRepo] ⚠️ Google Sign-In cancelled by user');
        return;
      }

      log('[AuthRepo] ✅ Google account selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      log('[AuthRepo] 🔑 Firebase credential created, signing in...');
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      log('[AuthRepo] ✅ Firebase sign-in successful');
      log(
        '[AuthRepo] 📋 User: ${userCredential.user?.email}, UID: ${userCredential.user?.uid}',
      );
      log(
        '[AuthRepo] 🆕 Is new user: ${userCredential.additionalUserInfo?.isNewUser}',
      );

      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        log('[AuthRepo] 🆕 New user detected, creating profile...');

        final user = userCredential.user!;
        final userProfile = UserProfile(
          id: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email!,
          createdAt: DateTime.now(),
        );

        log('[AuthRepo] 💾 Creating Google user profile document...');
        log('[AuthRepo] 📄 Profile data: ${userProfile.toString()}');

        final docRef = _firestore.collection('users').doc(user.uid);
        await docRef.set(userProfile.toJsonWithDateTime());

        log('[AuthRepo] ✅ Google user profile document created');

        // Verify creation
        final verifyDoc = await docRef.get();
        if (verifyDoc.exists) {
          log('[AuthRepo] ✅ Google profile creation verified');
          log('[AuthRepo] 📄 Verified data: ${verifyDoc.data()}');
        } else {
          log('[AuthRepo] ❌ Google profile creation verification FAILED');
          throw Exception('Failed to create Google user profile document');
        }
      } else if (userCredential.user != null) {
        log('[AuthRepo] 🔄 Existing user signed in');

        // For existing users, let's check if their profile exists
        final docRef = _firestore
            .collection('users')
            .doc(userCredential.user!.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          log(
            '[AuthRepo] ⚠️ Existing user has no profile document. Creating...',
          );
          await ensureUserProfileExists();
        } else {
          log('[AuthRepo] ✅ Existing user profile confirmed');
        }
      }
    } on FirebaseAuthException catch (e) {
      log(
        '[AuthRepo] ❌ FIREBASE AUTH ERROR during Google Sign In: ${e.code} - ${e.message}',
        error: e,
      );
      rethrow;
    } on FirebaseException catch (e) {
      log(
        '[AuthRepo] ❌ FIRESTORE ERROR during Google Sign In: ${e.code} - ${e.message}',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        '[AuthRepo] ❌ UNKNOWN ERROR during Google Sign In',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Helper method to verify document creation

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
