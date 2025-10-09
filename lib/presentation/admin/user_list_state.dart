part of 'user_list_cubit.dart';

abstract class UserListState {}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState with EquatableMixin {
  final List<User> users;
  UserListLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserListActionInProgress extends UserListState {}

class UserListSuccess extends UserListState {
  final String message;
  UserListSuccess({required this.message});
}

class UserListError extends UserListState {
  final String message;
  UserListError({required this.message});
}
