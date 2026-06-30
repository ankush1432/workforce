import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:supervisor_app/core/error/app_exception.dart';
import 'package:supervisor_app/core/utils/logger.dart';
import 'package:supervisor_app/features/auth/data/auth_local_datasource.dart';
import 'package:supervisor_app/features/auth/presentation/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 90),
    sendTimeout: const Duration(seconds: 60),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ));

  // Request interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Log request in debug mode
      AppLogger.apiRequest(
        options.method,
        options.uri.toString(),
        data: options.data,
      );

      // Add auth token
      final token = ref.read(authLocalDataSourceProvider).getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    },
    onResponse: (response, handler) {
      // Log response in debug mode
      AppLogger.apiResponse(
        response.requestOptions.uri.toString(),
        response.statusCode ?? 0,
        data: response.data,
      );
      handler.next(response);
    },
    onError: (error, handler) async {
      // Log error in debug mode
      AppLogger.apiError(
        error.requestOptions.uri.toString(),
        error: error.error,
        statusCode: error.response?.statusCode,
      );

      // Handle 401 unauthorized
      if (error.response?.statusCode == 401) {
        await ref.read(authLocalDataSourceProvider).clear();
        ref.invalidate(authStateProvider);
        
        // Reject with custom unauthorized exception
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: UnauthorizedException(),
        ));
        return;
      }

      handler.next(error);
    },
  ));

  return dio;
});
