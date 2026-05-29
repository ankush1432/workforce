import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/features/auth/data/auth_repository.dart';
import 'package:supervisor_app/features/auth/domain/auth_state.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return ref.read(authRepositoryProvider).checkSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).login(email, password));
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState(isAuthenticated: false));
  }
}
