import 'package:flutter/foundation.dart';

/// Centralized logger for debugging
class AppLogger {
  AppLogger._();

  static const String _tag = 'AppLogger';

  /// Log debug message
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[$_tag] DEBUG: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] INFO: $message');
    }
  }

  /// Log warning message
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[$_tag] WARNING: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[$_tag] ERROR: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log API request
  static void apiRequest(String method, String url, {dynamic data}) {
    if (kDebugMode) {
      debugPrint('[$_tag] API REQUEST: $method $url');
      if (data != null) {
        debugPrint('Data: $data');
      }
    }
  }

  /// Log API response
  static void apiResponse(String url, int statusCode, {dynamic data}) {
    if (kDebugMode) {
      debugPrint('[$_tag] API RESPONSE: $url - Status: $statusCode');
      if (data != null) {
        debugPrint('Data: $data');
      }
    }
  }

  /// Log API error
  static void apiError(String url, {dynamic error, int? statusCode}) {
    if (kDebugMode) {
      debugPrint('[$_tag] API ERROR: $url - Status: $statusCode');
      if (error != null) {
        debugPrint('Error: $error');
      }
    }
  }
}
