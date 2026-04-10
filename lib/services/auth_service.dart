import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await ApiService.post('auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
    });
    final data = response['data'] as Map<String, dynamic>;
    await ApiService.setToken(data['accessToken'] as String);
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('auth/login', {
      'email': email,
      'password': password,
    });
    final data = response['data'] as Map<String, dynamic>;
    await ApiService.setToken(data['accessToken'] as String);
    return data;
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}
