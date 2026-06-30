import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/error/error_handler.dart';
import 'package:supervisor_app/core/network/dio_client.dart';
import 'package:supervisor_app/features/auth/data/auth_local_datasource.dart';
import 'package:supervisor_app/features/auth/domain/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(authLocalDataSourceProvider));
});

class AuthRepository {
  AuthRepository(this._dio, this._local);

  final Dio _dio;
  final AuthLocalDataSource _local;

  Future<AuthState> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/supervisor/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data == null) {
        throw Exception('No response data from server');
      }

      final token = data['token'] as String?;
      if (token == null) {
        throw Exception('No token in response');
      }

      final supervisorData = data['supervisor'];
      if (supervisorData == null || supervisorData is! Map) {
        throw Exception('Invalid supervisor data in response');
      }
      final supervisor = Map<String, dynamic>.from(supervisorData);

      await _local.saveToken(token);
      await _local.saveProfile(supervisor);

      return AuthState(isAuthenticated: true, supervisor: supervisor);
    } on DioException catch (e) {
      debugPrint('Login error: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/supervisor/auth/logout');
    } catch (e) {
      debugPrint('Logout API error: $e');
      // Continue with local cleanup even if API call fails
    }
    await _local.clear();
  }

  AuthState checkSession() {
    final token = _local.getToken();
    final profile = _local.getProfile();
    if (token != null && profile != null) {
      return AuthState(isAuthenticated: true, supervisor: profile);
    }
    return const AuthState(isAuthenticated: false);
  }
}
