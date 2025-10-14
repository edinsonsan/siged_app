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
    dio.interceptors.add(
      InterceptorsWrapper(
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
        // OPCIONAL: Podrías poner el manejo de errores aquí en `onError` para DRY,
        // pero manejarlo en cada método es más simple por ahora.
      ),
    );
  }

  // --- NUEVO MÉTODO HELPER PARA MANEJAR ERRORES ---
  dynamic _handleDioError(DioException e) {
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      final errorData = e.response!.data as Map<String, dynamic>;

      // La mayoría de los frameworks (como NestJS) devuelven el mensaje en el campo 'message'
      final backendMessage = errorData['message'];

      if (backendMessage is String && backendMessage.isNotEmpty) {
        // Relanzamos una excepción de Dart simple con el mensaje del backend.
        // Esto será capturado en el try/catch del Flutter widget.
        throw Exception(backendMessage);
      }
    }

    // Si no es un error de respuesta HTTP (ej: timeout, sin conexión, etc.),
    // o no contiene un mensaje estructurado, relanzamos el error de Dio o uno genérico.
    final status = e.response?.statusCode;
    if (status != null) {
      throw Exception(
        'Error $status: ${e.response?.statusMessage ?? 'Ocurrió un error en el servidor.'}',
      );
    }

    throw Exception('Error de conexión: ${e.message}');
  }

  /// Simple GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    // Agregamos .catchError para interceptar DioException y relanzarla.
    return dio.get<T>(path, queryParameters: queryParameters).catchError((
      error,
    ) {
      if (error is DioException) {
        throw _handleDioError(error);
      }
      throw error;
    });
  }

  /// Simple POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio
        .post<T>(path, data: data, queryParameters: queryParameters)
        .catchError((error) {
          if (error is DioException) {
            throw _handleDioError(error);
          }
          throw error;
        });
  }

  /// Simple PATCH
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio
        .patch<T>(path, data: data, queryParameters: queryParameters)
        .catchError((error) {
          if (error is DioException) {
            throw _handleDioError(error);
          }
          throw error;
        });
  }

  /// Simple DELETE
  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.delete<T>(path, queryParameters: queryParameters).catchError((
      error,
    ) {
      if (error is DioException) {
        throw _handleDioError(error);
      }
      throw error;
    });
  }
}
