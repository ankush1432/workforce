/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Network exception for connectivity issues
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Timeout exception for request timeouts
class TimeoutException extends AppException {
  TimeoutException(super.message);
}

/// Unauthorized exception for 401 errors
class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Session expired. Please login again.'])
      : super(statusCode: 401);
}

/// Forbidden exception for 403 errors
class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'Access forbidden.'])
      : super(statusCode: 403);
}

/// Not found exception for 404 errors
class NotFoundException extends AppException {
  NotFoundException([super.message = 'Resource not found.'])
      : super(statusCode: 404);
}

/// Validation exception for 400 errors
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, {this.errors}) : super(statusCode: 400);
}

/// Server exception for 500 errors
class ServerException extends AppException {
  ServerException([super.message = 'Server error. Please try again later.'])
      : super(statusCode: 500);
}

/// Generic API exception
class ApiException extends AppException {
  ApiException(super.message, {super.statusCode});
}
