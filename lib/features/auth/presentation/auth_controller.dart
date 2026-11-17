import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  const AuthState(this.status, [this.user]);
}

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepository(ref.read(dioProvider), ref.read(tokenStorageProvider)),
);

final authControllerProvider =
NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    Future.microtask(restoreSession);
    return const AuthState(AuthStatus.unknown);
  }

  Future<void> restoreSession() async {
    if (!await _repo.hasToken()) {
      state = const AuthState(AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _repo.me();
      state = AuthState(AuthStatus.authenticated, user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) await _repo.clearToken();
      state = const AuthState(AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    final user = await _repo.login(email: email, password: password);
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> register(String name, String email, String password) async {
    final user = await _repo.register(name: name, email: email, password: password);
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(AuthStatus.unauthenticated);
  }

  void updateUser(UserModel user) =>
      state = AuthState(AuthStatus.authenticated, user);

  /// Called by the Dio interceptor when the server says the token is invalid.
  void sessionExpired() => state = const AuthState(AuthStatus.unauthenticated);
}