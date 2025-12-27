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
