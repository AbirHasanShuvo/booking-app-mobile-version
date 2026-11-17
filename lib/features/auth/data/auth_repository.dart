import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import 'user_model.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });
      return await _saveSession(res.data);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return await _saveSession(res.data);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<UserModel> me() async {
    try {
      final res = await _dio.get('/me');
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Even if the server call fails, we still clear the local session.
    } finally {
      await _storage.clear();
    }
  }

  Future<bool> hasToken() async => (await _storage.read()) != null;

  Future<void> clearToken() => _storage.clear();

  Future<UserModel> _saveSession(dynamic body) async {
    final data = body['data'] as Map<String, dynamic>;
    await _storage.save(data['access_token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}