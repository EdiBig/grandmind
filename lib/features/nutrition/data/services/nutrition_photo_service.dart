import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';

/// Callback for upload progress updates
typedef MealPhotoProgressCallback = void Function(double progress, String status);

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
      if (kDebugMode) {
        debugPrint('Error taking photo: $e');
      }
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
      if (kDebugMode) {
        debugPrint('Error picking photo: $e');
      }
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

  /// Upload photo to Firebase Storage with compression
  /// Returns the download URL
  /// Throws [ImageException] if upload fails
  Future<String> uploadMealPhoto(
    File photoFile,
    String userId, {
    MealPhotoProgressCallback? onProgress,
  }) async {
    File? compressedFile;
    try {
      onProgress?.call(0.0, 'Compressing image...');

      // Compress the image before upload
      compressedFile = await _compressImage(photoFile);

      onProgress?.call(0.2, 'Uploading photo...');

      final String photoId = const Uuid().v4();
      final String fileName = '${userId}_${photoId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('meal_photos/$userId/$fileName');

      // Upload the compressed file with progress tracking
      final UploadTask uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Upload is 20% to 95% of total progress
        onProgress?.call(0.2 + (progress * 0.75), 'Uploading photo...');
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      onProgress?.call(1.0, 'Complete!');

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase error uploading photo: $e');
      }
      throw ImageException.uploadError('Upload failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading photo: $e');
      }
      if (e is ImageException) rethrow;
      throw ImageException.uploadError('Failed to upload meal photo: $e');
    } finally {
      // Clean up temp file
      if (compressedFile != null && compressedFile.path != photoFile.path) {
        try {
          await compressedFile.delete();
        } catch (_) {}
      }
    }
  }

  /// Compress image to reduce file size and fix EXIF orientation
  /// Max width: 1920px, Quality: 85%
  /// Throws [ImageException] if compression fails
  Future<File> _compressImage(File imageFile, {int quality = 85}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      var image = img.decodeImage(imageBytes);

      if (image == null) {
        throw ImageException.decodeError();
      }

      // Apply EXIF orientation to fix rotated images (especially from iOS)
      image = img.bakeOrientation(image);

      // Resize if needed (max 1920px on longest side)
      if (image.width > 1920 || image.height > 1920) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: 1920);
        } else {
          image = img.copyResize(image, height: 1920);
        }
      }

      // Encode as JPEG
      final compressedBytes = img.encodeJpg(image, quality: quality);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/meal_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error compressing image: $e');
      }
      if (e is ImageException) rethrow;
      throw ImageException.compressionError('Failed to process image: $e');
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
      if (kDebugMode) {
        debugPrint('Error deleting photo: $e');
      }
      return false;
    }
  }

  /// Upload multiple photos (for future use)
  Future<List<String>> uploadMultiplePhotos(
    List<File> photoFiles,
    String userId, {
    MealPhotoProgressCallback? onProgress,
  }) async {
    final List<String> urls = [];
    final total = photoFiles.length;

    for (int i = 0; i < photoFiles.length; i++) {
      final file = photoFiles[i];
      onProgress?.call(i / total, 'Uploading photo ${i + 1} of $total...');
      try {
        final url = await uploadMealPhoto(file, userId);
        urls.add(url);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error uploading photo ${i + 1}: $e');
        }
        // Continue with remaining photos
      }
    }

    onProgress?.call(1.0, 'Complete!');
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
      if (kDebugMode) {
        debugPrint('Error getting image: $e');
      }
      return null;
    }
  }
}
