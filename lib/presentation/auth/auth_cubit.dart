import 'package:bloc/bloc.dart';
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
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout: delete token and emit UnaAuthenticated
  Future<void> logout() async {
    await SecureStorage.deleteAccessToken();
    emit(const AuthUnauthenticated());
  }
}
