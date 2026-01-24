import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service for handling account deletion
class AccountDeletionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Delete user account and all associated data
  /// This is irreversible!
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final userId = user.uid;

    try {
      // Step 1: Delete all Firestore data
      await _deleteFirestoreData(userId);

      // Step 2: Delete all Storage files
      await _deleteStorageFiles(userId);

      // Step 3: Delete Firebase Auth account
      await user.delete();

      if (kDebugMode) {
        debugPrint('Account successfully deleted for user: $userId');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Delete all user data from Firestore
  Future<void> _deleteFirestoreData(String userId) async {
    final batch = _firestore.batch();

    // Collections to delete
    final collections = [
      'habits',
      'habit_logs',
      'workout_logs',
      'weight_entries',
      'measurement_entries',
      'progress_photos',
      'progress_goals',
      'health_data',
      'notification_schedules',
      'notification_logs',
    ];

    // Delete from root-level collections
    for (final collectionName in collections) {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    // Delete user document and subcollections
    final userDocRef = _firestore.collection('users').doc(userId);

    // Delete notification preferences subcollection
    final notifPrefsSnapshot =
        await userDocRef.collection('notification_preferences').get();
    for (final doc in notifPrefsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete notification history subcollection
    final notifHistorySnapshot =
        await userDocRef.collection('notification_history').get();
    for (final doc in notifHistorySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete user document
    batch.delete(userDocRef);

    // Commit all deletions
    await batch.commit();
  }

  /// Delete all user files from Firebase Storage
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      // Delete profile photos
      await _deleteStorageFolder('profile_photos/$userId');
      await _deleteStorageFolder('public_profiles/$userId');

      // Delete progress photos
      await _deleteStorageFolder('progress_photos/$userId');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting storage files: $e');
      }
      // Continue even if storage deletion fails
    }
  }

  /// Delete all files in a Storage folder
  Future<void> _deleteStorageFolder(String folderPath) async {
    try {
      final listResult = await _storage.ref(folderPath).listAll();

      // Delete all files
      for (final fileRef in listResult.items) {
        await fileRef.delete();
      }

      // Delete all subfolders recursively
      for (final folderRef in listResult.prefixes) {
        await _deleteStorageFolder(folderRef.fullPath);
      }
    } catch (e) {
      // Folder might not exist, which is fine
      if (kDebugMode) {
        debugPrint('Error deleting folder $folderPath: $e');
      }
    }
  }

  /// Re-authenticate user before deletion (required by Firebase for security)
  Future<void> reauthenticateUser(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithApple() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final provider = OAuthProvider('apple.com');
    final credential = provider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    await user.reauthenticateWithCredential(credential);
  }
}
