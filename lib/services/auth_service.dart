import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

/// Holds sign-in state for the session. The JWT lives in memory only
/// (no persistence) — the user re-logs in on every app restart, which
/// is deliberate for now.
class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiService.baseUrl,
    connectTimeout: const Duration(seconds: 15),
  ));

  String? _token;
  String? _userEmail;

  bool get isLoggedIn => _token != null;
  bool get isGuest => _token == '__guest__';
  String get token => _token ?? '';
  String? get userEmail => _userEmail;

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      debugPrint('LOGIN RESPONSE: ${response.data}');

      _token = response.data['access_token'] as String;
      _userEmail = email;

      debugPrint('TOKEN SAVED: ${_token != null}');
      debugPrint('TOKEN LENGTH: ${_token?.length ?? 0}');

    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Login failed'));
    }
  }

  Future<void> signup({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
      });
      _token = response.data['access_token'] as String;
      _userEmail = email;
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Signup failed'));
    }
  }

  /// Skips API login and creates a guest session in memory.
  void loginAsGuest() {
    _token = '__guest__';
    _userEmail = 'Guest';
  }

  void logout() {
    _token = null;
    _userEmail = null;
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach the server. Is the backend running on 127.0.0.1:8000?';
    }
    return fallback;
  }
}
