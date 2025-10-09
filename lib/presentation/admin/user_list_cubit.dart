import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/admin_repository.dart';

part 'user_list_state.dart';

class UserListCubit extends Cubit<UserListState> {
  final AdminRepository repository;

  UserListCubit(this.repository) : super(UserListInitial());

  Future<void> loadUsers() async {
    emit(UserListLoading());
    try {
      final users = await repository.getUsers();
      emit(UserListLoaded(users: users));
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }

  Future<void> createUser(Map<String, dynamic> dto) async {
    emit(UserListActionInProgress());
    try {
      await repository.createUser(dto);
      await loadUsers();
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }

  Future<void> updateUser(num id, Map<String, dynamic> dto) async {
    emit(UserListActionInProgress());
    try {
      await repository.updateUser(id, dto);
      await loadUsers();
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }

  Future<void> deleteUser(num id) async {
    emit(UserListActionInProgress());
    try {
      await repository.deleteUser(id);
      await loadUsers();
    } catch (e) {
      emit(UserListError(message: e.toString()));
    }
  }
}
