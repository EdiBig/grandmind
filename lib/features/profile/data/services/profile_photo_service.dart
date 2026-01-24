import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/exceptions.dart';

/// Service for uploading and managing profile photos
class ProfilePhotoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const int _maxProfilePhotoBytes = 5 * 1024 * 1024;

  /// Upload a profile photo with compression
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    File? compressedImage;
    try {
      // Compress image
      compressedImage = await _compressImageFile(imageFile);

      // Upload to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'public_profiles/$userId/profile_$timestamp.jpg';
      final ref = _storage.ref().child(path);

      await ref.putFile(
        compressedImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ImageException.uploadError('Profile photo upload failed: ${e.message}');
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException.uploadError('Failed to upload profile photo: $e');
    } finally {
      // Clean up temp file
      if (compressedImage != null) {
        try {
          await compressedImage.delete();
        } catch (_) {}
      }
    }
  }

  /// Upload profile photo from raw bytes (web support)
  Future<String> uploadProfilePhotoBytes({
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final compressedBytes = _compressImageBytes(bytes);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'public_profiles/$userId/profile_$timestamp.jpg';
      final ref = _storage.ref().child(path);

      await ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ImageException.uploadError('Profile photo upload failed: ${e.message}');
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException.uploadError('Failed to upload profile photo: $e');
    }
  }

  /// Delete a profile photo from Storage
  Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      // Extract path from URL
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      // Silently fail - photo might already be deleted
      if (kDebugMode) {
        debugPrint('Failed to delete profile photo: $e');
      }
    }
  }

  /// Migrate legacy profile photo from private path to public path.
  /// Returns the new URL if migration occurred, otherwise null.
  Future<String?> migrateLegacyProfilePhoto({
    required String userId,
    required String? photoUrl,
  }) async {
    if (photoUrl == null || photoUrl.trim().isEmpty) return null;
    final trimmedUrl = photoUrl.trim();

    if (!_isLegacyProfilePhotoUrl(trimmedUrl)) return null;

    try {
      final oldRef = _storage.refFromURL(trimmedUrl);
      if (!oldRef.fullPath.startsWith('profile_photos/$userId/')) {
        return null;
      }

      final metadata = await oldRef.getMetadata();
      final bytes = await oldRef.getData(_maxProfilePhotoBytes);
      if (bytes == null || bytes.isEmpty) return null;

      final newRef =
          _storage.ref().child('public_profiles/$userId/${oldRef.name}');
      await newRef.putData(
        bytes,
        SettableMetadata(
          contentType: metadata.contentType ?? 'image/jpeg',
        ),
      );

      final newUrl = await newRef.getDownloadURL();
      try {
        await oldRef.delete();
      } catch (_) {
        // Best-effort cleanup; ignore deletion failures.
      }
      return newUrl;
    } catch (_) {
      return null;
    }
  }

  bool _isLegacyProfilePhotoUrl(String url) {
    if (url.contains('public_profiles')) return false;
    return url.contains('/profile_photos/') || url.contains('profile_photos%2F');
  }

  /// Compress image to reduce file size
  /// Max dimensions: 512x512px, Quality: 90%
  Future<File> _compressImageFile(File imageFile, {int quality = 90}) async {
    try {
      // Read image
      final imageBytes = await imageFile.readAsBytes();
      final compressedBytes = _compressImageBytes(imageBytes, quality: quality);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg'
      );
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException.compressionError('Failed to compress profile photo: $e');
    }
  }

  Uint8List _compressImageBytes(Uint8List imageBytes, {int quality = 90}) {
    var image = img.decodeImage(imageBytes);

    if (image == null) {
      throw ImageException.decodeError();
    }

    // Apply EXIF orientation to fix rotated images (especially from iOS)
    image = img.bakeOrientation(image);

    // Resize to square (512x512) - crop to center
    final size = 512;
    img.Image resized;

    if (image.width > image.height) {
      // Landscape - crop width
      final cropWidth = image.height;
      final cropX = (image.width - cropWidth) ~/ 2;
      final cropped = img.copyCrop(
        image,
        x: cropX,
        y: 0,
        width: cropWidth,
        height: image.height,
      );
      resized = img.copyResize(cropped, width: size, height: size);
    } else {
      // Portrait or square - crop height
      final cropHeight = image.width;
      final cropY = (image.height - cropHeight) ~/ 2;
      final cropped = img.copyCrop(
        image,
        x: 0,
        y: cropY,
        width: image.width,
        height: cropHeight,
      );
      resized = img.copyResize(cropped, width: size, height: size);
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }
}
