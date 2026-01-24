import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/data/services/firestore_service.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;
  final AnalyticsService _analytics;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirestoreService? firestoreService,
    AnalyticsService? analytics,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestoreService = firestoreService ?? FirestoreService(),
        _analytics = analytics ?? AnalyticsService();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await ensureUserProfile(user);
        await _analytics.setUserId(user.uid);
        await _analytics.logLogin(method: 'email');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (userCredential.user != null) {
        final now = DateTime.now();
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          signInProvider: userCredential.user!.providerData.isNotEmpty
              ? userCredential.user!.providerData.first.providerId
              : null,
          hasCompletedOnboarding: false,
          onboarding: const {'completed': false},
          createdAt: now,
          updatedAt: now,
        );
        await _firestoreService.createUser(userModel);

        // Update display name in Firebase Auth if provided
        if (displayName != null) {
          await userCredential.user!.updateDisplayName(displayName);
        }

        // Track sign up
        await _analytics.setUserId(userCredential.user!.uid);
        await _analytics.logSignUp(method: 'email');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await _firebaseAuth.signInWithRedirect(provider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw const AuthException(
            message: 'Google sign-in canceled',
            code: 'sign-in-cancelled',
          );
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        if (userCredential.user != null) {
          await ensureUserProfile(userCredential.user!);
          await _analytics.setUserId(userCredential.user!.uid);
          await _analytics.logLogin(method: 'google');
        }
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(message: 'Google sign-in failed: $e');
    }
  }

  Future<void> handleWebRedirectResult() async {
    if (!kIsWeb) return;
    try {
      final result = await _firebaseAuth.getRedirectResult();
      if (result.user != null) {
        await ensureUserProfile(result.user!);
      }
    } catch (_) {
      // Ignore redirect result errors to avoid blocking app load.
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((value) => value?.isNotEmpty ?? false).join(' ').trim();

        await ensureUserProfile(
          userCredential.user!,
          overrideDisplayName: displayName,
        );
        await _analytics.setUserId(userCredential.user!.uid);
        await _analytics.logLogin(method: 'apple');
      }

      return userCredential;
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signOut() async {
    await _analytics.logLogout();
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      await _analytics.logPasswordResetRequested();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel> ensureUserProfile(
    User user, {
    String? overrideDisplayName,
  }) async {
    final existingUser = await _firestoreService.getUser(user.uid);
    if (existingUser != null) {
      return existingUser;
    }

    final now = DateTime.now();
    final displayName =
        (overrideDisplayName != null && overrideDisplayName.isNotEmpty)
            ? overrideDisplayName
            : user.displayName;
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : null;

    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: user.photoURL,
      hasCompletedOnboarding: false,
      signInProvider: providerId,
      onboarding: const {'completed': false},
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.createUser(userModel);
    return userModel;
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
