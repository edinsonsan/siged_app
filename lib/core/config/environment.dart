import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple static Environment loader.
/// Usage:
/// await Environment.initEnvironment();
/// final url = Environment.apiUrl;
class Environment {
  static String? _apiUrl;

  Environment._();

  /// Loads .env located at project root and reads API_URL
  static Future<void> initEnvironment() async {
    // Load the .env file. If already loaded, this will be a no-op.
    await dotenv.load();
    _apiUrl = dotenv.env['API_URL'] ?? dotenv.get('API_URL', fallback: null);
  }

  /// Accessor for the API URL. Throws if not initialized.
  static String get apiUrl {
    if (_apiUrl == null) {
      throw StateError('Environment not initialized. Call Environment.initEnvironment() before accessing apiUrl.');
    }
    return _apiUrl!;
  }
}
