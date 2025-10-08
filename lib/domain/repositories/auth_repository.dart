import 'package:dio/dio.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/secure_storage.dart';
import '../models/user.dart';

class AuthRepository {
  final DioHttpService httpService;

  AuthRepository(this.httpService);

  /// Attempts to login and saves the JWT token in secure storage.
  /// Throws a [DioException] or generic [Exception] on failure.
  Future<void> login(String email, String password) async {
    final response = await httpService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    // Try to extract token from common locations in the response body
    final data = response.data;

    String? token;
    if (data is Map<String, dynamic>) {
      token = (data['access_token'] ?? data['token'] ?? data['jwt'] ?? data['accessToken']) as String?;
      // Some APIs wrap token in data.token or similar
      if (token == null) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final inner = data['data'] as Map<String, dynamic>;
          token = (inner['access_token'] ?? inner['token'] ?? inner['jwt'] ?? inner['accessToken']) as String?;
        }
      }
    }

    // Also check for Authorization header
    if (token == null) {
      final authHeader = response.headers.value('authorization') ?? response.headers.value('Authorization');
      if (authHeader != null) {
        // header could be 'Bearer <token>'
        token = authHeader.replaceFirst(RegExp(r'^[bB]earer\s+'), '');
      }
    }

    if (token == null || token.isEmpty) {
      throw Exception('Login successful but no token found in response');
    }

    await SecureStorage.setAccessToken(token);
  }

  /// Fetches profile of logged in user and returns a [User].
  Future<User> getProfile() async {
    final response = await httpService.get('/auth/profile');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }
    throw Exception('Invalid profile response');
  }
}
