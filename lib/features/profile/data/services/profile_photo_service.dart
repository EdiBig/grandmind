import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Service for uploading and managing profile photos
class ProfilePhotoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a profile photo with compression
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Compress image
      final compressedImage = await _compressImageFile(imageFile);

      // Upload to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'profile_photos/$userId/profile_$timestamp.jpg';
      final ref = _storage.ref().child(path);

      await ref.putFile(compressedImage);
      final downloadUrl = await ref.getDownloadURL();

      // Clean up temp file
      await compressedImage.delete();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
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
      final path = 'profile_photos/$userId/profile_$timestamp.jpg';
      final ref = _storage.ref().child(path);

      await ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
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
      debugPrint('Failed to delete profile photo: $e');
    }
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
      throw Exception('Failed to compress image: $e');
    }
  }

  Uint8List _compressImageBytes(Uint8List imageBytes, {int quality = 90}) {
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

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
