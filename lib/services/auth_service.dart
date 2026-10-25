import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

/// Holds sign-in state for the session. The JWT lives in memory only
/// (no persistence) — the user re-logs in on every app restart, which
/// is deliberate for now.
class AuthService {
  final Dio _dio = Dio(BaseOptions(
  baseUrl: ApiService.baseUrl,
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 60),
  ));

  String? _token;
  String? _userEmail;

  bool get isLoggedIn => _token != null;
  bool get isGuest => _token == '__guest__';
  String get token => _token ?? '';
  String? get userEmail => _userEmail;

  /// Pings the backend so a sleeping server starts waking up.
  /// Fire-and-forget: errors are ignored.
  Future<void> wakeServer() async {
    try {
      await _dio.get('/health');
    } catch (_) {}
  }

  /// Retries a request a few times (for cold starts).
  Future<Response> _postWithRetry(String path, Map<String, dynamic> data,
    {int retries = 4}) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await _dio.post(path, data: data);
      } on DioException catch (e) {
        final isNetworkIssue = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
        if (!isNetworkIssue || attempt >= retries) rethrow;
       await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await _postWithRetry('/auth/login', {
      'email': email,
      'password': password,
    });

    debugPrint('LOGIN RESPONSE: ${response.data}');

    _token = response.data['access_token'] as String;
    _userEmail = email;

    debugPrint('TOKEN SAVED: ${_token != null}');
    debugPrint('TOKEN LENGTH: ${_token?.length ?? 0}');
  } on DioException catch (e) {
    debugPrint('LOGIN ERROR: ${e.response?.statusCode}');
    debugPrint('ERROR RESPONSE: ${e.response?.data}');
    throw Exception(_extractError(e, 'Login failed'));
  }
}

  Future<void> signup({required String email, required String password}) async {
    try {
      final response = await _postWithRetry('/auth/signup', {
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
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
      return 'The server is waking up or unreachable. Please wait a moment and try again.';
    }
    return fallback;
  }
}
