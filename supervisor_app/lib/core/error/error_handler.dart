import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'app_exception.dart';

/// Centralized error handler for parsing and converting Dio errors to AppExceptions
class ErrorHandler {
  /// Parse DioException and return appropriate AppException
  static AppException handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    return ApiException('An unexpected error occurred.');
  }

  /// Handle DioException and convert to appropriate AppException
  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timed out. Please check your connection.');

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, error.response?.data);

      case DioExceptionType.cancel:
        return ApiException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');

      case DioExceptionType.unknown:
        if (error.error is SocketException || error.message?.contains('SocketException') == true) {
          return NetworkException('No internet connection. Please check your network.');
        }
        return ApiException('An unexpected error occurred: ${error.message}');

      default:
        return ApiException('An unexpected error occurred.');
    }
  }

  /// Handle HTTP status codes
  static AppException _handleStatusCode(int? statusCode, dynamic data) {
    final message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        final errors = _extractErrors(data);
        return ValidationException(message, errors: errors);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message);
      default:
        return ApiException(message);
    }
  }

  /// Extract error message from response data
  static String _extractMessage(dynamic data) {
    if (data == null) return 'An error occurred.';

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 
             data['error']?.toString() ?? 
             'An error occurred.';
    }

    return data.toString();
  }

  /// Extract backend message from DioException response
  static String extractBackendMessage(DioException e) {
    // Extract backend message from response.data
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      
      // Try message field first
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      
      // Try error field
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) {
        return error;
      }
      
      // Try errors field
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        try {
          final firstError = errors.values.first;
          if (firstError != null) {
            return firstError.toString();
          }
        } catch (e) {
          debugPrint('Error extracting from errors field: $e');
        }
      }
    }
    
    // Fallback to user-friendly error messages based on status code
    final statusCode = e.response?.statusCode;
    switch (statusCode) {
      case 401:
        return 'Authentication failed. Please log in again.';
      case 404:
        return 'Resource not found. Please check and try again.';
      case 422:
        return 'Validation failed. Please check your input and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return 'Request failed with status code $statusCode. Please try again.';
        }
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract validation errors from response data
  static Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors;
      }
    }
    return null;
  }

  /// Get user-friendly error message
  static String getUserMessage(AppException exception) {
    return exception.message;
  }

  /// Log error for debugging
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('Error: ${error.toString()}');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
}
