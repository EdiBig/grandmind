import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Service for handling meal photos
/// Uploads photos to Firebase Storage and manages photo URLs
class NutritionPhotoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Take a photo from camera
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Pick a photo from gallery
  Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error picking photo: $e');
      return null;
    }
  }

  /// Show photo source picker (camera or gallery)
  /// Returns the selected photo file or null if cancelled
  Future<File?> pickPhotoSource() async {
    // This method is meant to be used with a dialog
    // The dialog should be shown in the UI layer
    // This is just a helper that the UI can use
    return null;
  }

  /// Upload photo to Firebase Storage
  /// Returns the download URL or null if failed
  Future<String?> uploadMealPhoto(File photoFile, String userId) async {
    try {
      final String photoId = const Uuid().v4();
      final String fileName = '${userId}_${photoId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('meal_photos/$userId/$fileName');

      // Upload the file
      final UploadTask uploadTask = ref.putFile(
        photoFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }

  /// Delete photo from Firebase Storage
  /// Takes the full download URL and extracts the path to delete
  Future<bool> deletePhotoByUrl(String photoUrl) async {
    try {
      // Extract the storage path from the download URL
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  /// Upload multiple photos (for future use)
  Future<List<String>> uploadMultiplePhotos(
    List<File> photoFiles,
    String userId,
  ) async {
    final List<String> urls = [];

    for (final file in photoFiles) {
      final url = await uploadMealPhoto(file, userId);
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  /// Get image from camera or gallery (helper method)
  Future<File?> getImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error getting image: $e');
      return null;
    }
  }
}
