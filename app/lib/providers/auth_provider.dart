import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(sharedPreferencesProvider));
});

const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api',
);

final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(
    baseUrl: _apiBaseUrl,
    authService: authService,
  );
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  bool get isRegisteredUser => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final AuthService _auth;

  AuthNotifier(this._api, this._auth) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _api.login(email: email, password: password);
      await _auth.saveToken(token);
      final user = await _api.getMe();
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '登录失败，请检查账号密码');
      return false;
    }
  }

  Future<bool> register(String email, String password, String nickname) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _api.register(
        email: email,
        password: password,
        nickname: nickname,
      );
      await _auth.saveToken(token);
      final user = await _api.getMe();
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '注册失败，请稍后重试');
      return false;
    }
  }

  void updateUser(User user) {
    state = AuthState(user: user);
  }

  Future<void> logout() async {
    await _auth.clearSession();
    state = const AuthState();
  }

}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(authServiceProvider),
  );
});
