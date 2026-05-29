import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final response = await _dio.post('/auth/supervisor/login', data: {
      'email': email,
      'password': password,
    });

    final token = response.data['token'] as String;
    final supervisor = Map<String, dynamic>.from(response.data['supervisor'] as Map);

    await _local.saveToken(token);
    await _local.saveProfile(supervisor);

    return AuthState(isAuthenticated: true, supervisor: supervisor);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/supervisor/auth/logout');
    } catch (_) {}
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
