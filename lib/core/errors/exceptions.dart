/// Custom exceptions for the application
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
  });
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
  });
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
  });
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
  });
}

/// Image processing exceptions
class ImageException extends AppException {
  final ImageErrorType type;

  const ImageException({
    required super.message,
    required this.type,
    super.code,
  });

  factory ImageException.decodeError([String? details]) {
    return ImageException(
      message: details ?? 'Failed to decode image. The file may be corrupted or in an unsupported format.',
      type: ImageErrorType.decode,
      code: 'IMAGE_DECODE_ERROR',
    );
  }

  factory ImageException.compressionError([String? details]) {
    return ImageException(
      message: details ?? 'Failed to compress image.',
      type: ImageErrorType.compression,
      code: 'IMAGE_COMPRESSION_ERROR',
    );
  }

  factory ImageException.uploadError([String? details]) {
    return ImageException(
      message: details ?? 'Failed to upload image. Please check your connection and try again.',
      type: ImageErrorType.upload,
      code: 'IMAGE_UPLOAD_ERROR',
    );
  }

  factory ImageException.fileTooLarge(int maxSizeMB) {
    return ImageException(
      message: 'Image file is too large. Maximum size is ${maxSizeMB}MB.',
      type: ImageErrorType.fileTooLarge,
      code: 'IMAGE_FILE_TOO_LARGE',
    );
  }

  factory ImageException.unsupportedFormat() {
    return ImageException(
      message: 'Unsupported image format. Please use JPG, PNG, or WebP.',
      type: ImageErrorType.unsupportedFormat,
      code: 'IMAGE_UNSUPPORTED_FORMAT',
    );
  }
}

enum ImageErrorType {
  decode,
  compression,
  upload,
  fileTooLarge,
  unsupportedFormat,
}
