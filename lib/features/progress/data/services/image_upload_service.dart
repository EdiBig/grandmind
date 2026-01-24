import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/progress_photo.dart';

/// Callback for upload progress updates
/// [progress] is a value between 0.0 and 1.0
/// [status] describes the current upload stage
typedef UploadProgressCallback = void Function(double progress, String status);

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

  /// Upload a progress photo from raw bytes (web-friendly).
  Future<ImageUploadResult> uploadProgressPhotoBytes({
    required String userId,
    required Uint8List imageBytes,
    required PhotoAngle angle,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(0.0, 'Compressing image...');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final angleName = angle.name;

      final compressedBytes = _compressBytes(imageBytes);
      final thumbnailBytes = _generateThumbnailBytes(compressedBytes);
      final metadata = _getImageMetadataFromBytes(compressedBytes);

      onProgress?.call(0.1, 'Uploading photo...');

      final fullImagePath =
          '${FirebaseConstants.progressPhotosPath}/$userId/${timestamp}_${angleName}_full.jpg';
      final fullImageRef = _storage.ref().child(fullImagePath);

      // Upload with progress tracking
      final fullImageTask = fullImageRef.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to progress
      fullImageTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Full image upload is 10% to 70% of total progress
        onProgress?.call(0.1 + (progress * 0.6), 'Uploading photo...');
      });

      await fullImageTask;
      final fullImageUrl = await fullImageRef.getDownloadURL();

      onProgress?.call(0.75, 'Uploading thumbnail...');

      final thumbnailPath =
          '${FirebaseConstants.progressPhotosPath}/$userId/${timestamp}_${angleName}_thumb.jpg';
      final thumbnailRef = _storage.ref().child(thumbnailPath);

      final thumbTask = thumbnailRef.putData(
        thumbnailBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      thumbTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Thumbnail upload is 75% to 95% of total progress
        onProgress?.call(0.75 + (progress * 0.2), 'Uploading thumbnail...');
      });

      await thumbTask;
      final thumbnailUrl = await thumbnailRef.getDownloadURL();

      onProgress?.call(1.0, 'Complete!');

      return ImageUploadResult(
        imageUrl: fullImageUrl,
        thumbnailUrl: thumbnailUrl,
        storagePath: fullImagePath,
        metadata: metadata,
      );
    } on FirebaseException catch (e) {
      throw ImageException.uploadError('Upload failed: ${e.message}');
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException.uploadError('Failed to upload progress photo: $e');
    }
  }

  /// Upload a progress photo with compression and thumbnail generation
  Future<ImageUploadResult> uploadProgressPhoto({
    required String userId,
    required File imageFile,
    required PhotoAngle angle,
    UploadProgressCallback? onProgress,
  }) async {
    File? compressedImage;
    File? thumbnail;
    try {
      onProgress?.call(0.0, 'Compressing image...');

      // Generate unique timestamp for file naming
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final angleName = angle.name;

      // Compress original image
      compressedImage = await _compressImage(imageFile);
      onProgress?.call(0.05, 'Generating thumbnail...');

      // Generate thumbnail
      thumbnail = await _generateThumbnail(compressedImage);
      onProgress?.call(0.1, 'Uploading photo...');

      // Get image metadata
      final metadata = await _getImageMetadata(compressedImage);

      // Upload full image with progress tracking
      final fullImagePath =
          '${FirebaseConstants.progressPhotosPath}/$userId/${timestamp}_${angleName}_full.jpg';
      final fullImageRef = _storage.ref().child(fullImagePath);

      final fullImageTask = fullImageRef.putFile(compressedImage);

      fullImageTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Full image upload is 10% to 70% of total progress
        onProgress?.call(0.1 + (progress * 0.6), 'Uploading photo...');
      });

      await fullImageTask;
      final fullImageUrl = await fullImageRef.getDownloadURL();

      onProgress?.call(0.75, 'Uploading thumbnail...');

      // Upload thumbnail with progress tracking
      final thumbnailPath =
          '${FirebaseConstants.progressPhotosPath}/$userId/${timestamp}_${angleName}_thumb.jpg';
      final thumbnailRef = _storage.ref().child(thumbnailPath);

      final thumbTask = thumbnailRef.putFile(thumbnail);

      thumbTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Thumbnail upload is 75% to 95% of total progress
        onProgress?.call(0.75 + (progress * 0.2), 'Uploading thumbnail...');
      });

      await thumbTask;
      final thumbnailUrl = await thumbnailRef.getDownloadURL();

      onProgress?.call(1.0, 'Complete!');

      return ImageUploadResult(
        imageUrl: fullImageUrl,
        thumbnailUrl: thumbnailUrl,
        storagePath: fullImagePath,
        metadata: metadata,
      );
    } on FirebaseException catch (e) {
      throw ImageException.uploadError('Upload failed: ${e.message}');
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException.uploadError('Failed to upload progress photo: $e');
    } finally {
      // Clean up temporary files
      try {
        await compressedImage?.delete();
        await thumbnail?.delete();
      } catch (_) {}
    }
  }

  /// Compress image to reduce file size
  /// Max width: 1920px, Quality: 85%
  Future<File> _compressImage(File imageFile, {int quality = 85}) async {
    try {
      // Read image
      final imageBytes = await imageFile.readAsBytes();
      var image = img.decodeImage(imageBytes);

      if (image == null) {
        throw ImageException.decodeError();
      }

      // Apply EXIF orientation to fix rotated images (especially from iOS)
      image = img.bakeOrientation(image);

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
      if (e is ImageException) rethrow;
      throw ImageException.compressionError('Failed to compress image: $e');
    }
  }

  Uint8List _compressBytes(Uint8List imageBytes, {int quality = 85}) {
    var image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ImageException.decodeError();
    }
    // Apply EXIF orientation to fix rotated images (especially from iOS)
    image = img.bakeOrientation(image);
    final resized =
        image.width > 1920 ? img.copyResize(image, width: 1920) : image;
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  /// Generate a thumbnail (max width: 300px)
  Future<File> _generateThumbnail(File originalImage, {int maxWidth = 300, int quality = 80}) async {
    try {
      // Read image
      final imageBytes = await originalImage.readAsBytes();
      var image = img.decodeImage(imageBytes);

      if (image == null) {
        throw ImageException.decodeError('Failed to decode image for thumbnail generation');
      }

      // Apply EXIF orientation to fix rotated images
      image = img.bakeOrientation(image);

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
      if (e is ImageException) rethrow;
      throw ImageException.compressionError('Failed to generate thumbnail: $e');
    }
  }

  Uint8List _generateThumbnailBytes(
    Uint8List imageBytes, {
    int maxWidth = 300,
    int quality = 80,
  }) {
    var image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ImageException.decodeError('Failed to decode image for thumbnail generation');
    }
    // Apply EXIF orientation to fix rotated images
    image = img.bakeOrientation(image);
    final thumbnail = img.copyResize(image, width: maxWidth);
    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: quality));
  }

  /// Get image metadata (dimensions, file size)
  Future<Map<String, dynamic>> _getImageMetadata(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      var image = img.decodeImage(imageBytes);

      if (image == null) {
        return {};
      }

      // Apply EXIF orientation to get correct dimensions
      image = img.bakeOrientation(image);

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

  Map<String, dynamic> _getImageMetadataFromBytes(Uint8List imageBytes) {
    try {
      var image = img.decodeImage(imageBytes);
      if (image == null) {
        return {};
      }
      // Apply EXIF orientation to get correct dimensions
      image = img.bakeOrientation(image);
      return {
        'width': image.width,
        'height': image.height,
        'fileSize': imageBytes.length,
        'aspectRatio': image.width / image.height,
      };
    } catch (_) {
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
    } on FirebaseException catch (e) {
      throw ImageException.uploadError('Failed to delete photo: ${e.message}');
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException.uploadError('Failed to delete progress photo: $e');
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
