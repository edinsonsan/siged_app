import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/secure_storage.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(const AuthInitial());

  /// Checks if a token exists and fetches profile
  Future<void> checkAuthStatus() async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await repository.getProfile();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Login and fetch profile
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      await repository.login(email, password);
      final user = await repository.getProfile();
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      // 👈 Sé específico con el tipo de excepción
      String errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';

      // Verifica si el error tiene una respuesta del servidor con datos
      if (e.response?.data != null && e.response!.data is Map) {
        // Extrae el mensaje del JSON del backend
        errorMessage = e.response!.data['message'] ?? 'Error de autenticación.';
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'No se pudo conectar al servidor. Revisa tu conexión a internet.';
      }

      emit(AuthError(errorMessage));
    } catch (e) {
      // 👈 Un catch genérico para cualquier otro tipo de error
      emit(AuthError('Correo electrónico o contraseña incorrectos.'));
      // emit(AuthError('Ocurrió un error desconocido.'));
    }
  }

  /// Logout: delete token and emit UnaAuthenticated
  Future<void> logout() async {
    await SecureStorage.deleteAccessToken();
    emit(const AuthUnauthenticated());
  }
}
