import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../domain/models/progress_photo.dart';

/// Result of an image upload operation
class ImageUploadResult {
  final String imageUrl;
  final String thumbnailUrl;
  final String storagePath;
  final Map<String, dynamic> metadata;

  ImageUploadResult({
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.storagePath,
    required this.metadata,
  });
}

/// Service for uploading and managing progress photos
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a progress photo with compression and thumbnail generation
  Future<ImageUploadResult> uploadProgressPhoto({
    required String userId,
    required File imageFile,
    required PhotoAngle angle,
  }) async {
    try {
      // Generate unique timestamp for file naming
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final angleName = angle.name;

      // Compress original image
      final compressedImage = await _compressImage(imageFile);

      // Generate thumbnail
      final thumbnail = await _generateThumbnail(compressedImage);

      // Get image metadata
      final metadata = await _getImageMetadata(compressedImage);

      // Upload full image
      final fullImagePath =
          '${FirebaseConstants.progressPhotosPath}/$userId/${timestamp}_${angleName}_full.jpg';
      final fullImageRef = _storage.ref().child(fullImagePath);
      await fullImageRef.putFile(compressedImage);
      final fullImageUrl = await fullImageRef.getDownloadURL();

      // Upload thumbnail
      final thumbnailPath =
          '${FirebaseConstants.progressPhotosPath}/$userId/${timestamp}_${angleName}_thumb.jpg';
      final thumbnailRef = _storage.ref().child(thumbnailPath);
      await thumbnailRef.putFile(thumbnail);
      final thumbnailUrl = await thumbnailRef.getDownloadURL();

      // Clean up temporary files
      await compressedImage.delete();
      await thumbnail.delete();

      return ImageUploadResult(
        imageUrl: fullImageUrl,
        thumbnailUrl: thumbnailUrl,
        storagePath: fullImagePath,
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to upload progress photo: $e');
    }
  }

  /// Compress image to reduce file size
  /// Max width: 1920px, Quality: 85%
  Future<File> _compressImage(File imageFile, {int quality = 85}) async {
    try {
      // Read image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed (max width 1920px)
      final resized = image.width > 1920
          ? img.copyResize(image, width: 1920)
          : image;

      // Encode as JPEG with quality
      final compressedBytes = img.encodeJpg(resized, quality: quality);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Generate a thumbnail (max width: 300px)
  Future<File> _generateThumbnail(File originalImage, {int maxWidth = 300, int quality = 80}) async {
    try {
      // Read image
      final imageBytes = await originalImage.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image for thumbnail');
      }

      // Resize to thumbnail size
      final thumbnail = img.copyResize(image, width: maxWidth);

      // Encode as JPEG
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: quality);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(thumbnailBytes);

      return tempFile;
    } catch (e) {
      throw Exception('Failed to generate thumbnail: $e');
    }
  }

  /// Get image metadata (dimensions, file size)
  Future<Map<String, dynamic>> _getImageMetadata(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return {};
      }

      final fileSize = await imageFile.length();

      return {
        'width': image.width,
        'height': image.height,
        'fileSize': fileSize,
        'aspectRatio': image.width / image.height,
      };
    } catch (e) {
      return {};
    }
  }

  /// Delete a progress photo from Firebase Storage
  Future<void> deleteProgressPhoto(String imageUrl) async {
    try {
      // Extract path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      // Also try to delete thumbnail (best effort)
      final thumbnailPath = imageUrl.replaceAll('_full.jpg', '_thumb.jpg');
      try {
        final thumbRef = _storage.refFromURL(thumbnailPath);
        await thumbRef.delete();
      } catch (_) {
        // Thumbnail deletion failed, but continue
      }
    } catch (e) {
      throw Exception('Failed to delete progress photo: $e');
    }
  }

  /// Get the storage path from a download URL
  String getStoragePathFromUrl(String url) {
    try {
      final ref = _storage.refFromURL(url);
      return ref.fullPath;
    } catch (e) {
      return '';
    }
  }
}
