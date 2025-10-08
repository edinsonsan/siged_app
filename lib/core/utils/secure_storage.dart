import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A small helper wrapper around FlutterSecureStorage for JWT access token.
class SecureStorage {
  static const _accessTokenKey = 'ACCESS_TOKEN';

  // Use a single instance for the app
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save JWT access token
  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Read JWT access token, or null if not set
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Delete stored access token
  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }
}
