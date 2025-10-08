import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../utils/secure_storage.dart';

/// A simple Dio-based HTTP service that attaches a Bearer token from SecureStorage.
class DioHttpService {
  final Dio dio;

  DioHttpService(this.dio) {
    // Configure base options
    dio.options.baseUrl = Environment.apiUrl;
    // Add interceptor to attach Authorization header
    dio.interceptors.add(QueuedInterceptor());
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await SecureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // If reading token fails, continue without it
        }
        return handler.next(options);
      },
    ));
  }

  /// Simple GET
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  /// Simple POST
  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  /// Simple PATCH
  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  /// Simple DELETE
  Future<Response<T>> delete<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.delete<T>(path, queryParameters: queryParameters);
  }
}
