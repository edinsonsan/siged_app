part of 'area_list_cubit.dart';

abstract class AreaListState {}

class AreaListInitial extends AreaListState {}

class AreaListLoading extends AreaListState {}

class AreaListLoaded extends AreaListState with EquatableMixin {
  final List<Area> areas;
  AreaListLoaded({required this.areas});

  @override
  List<Object?> get props => [areas];
}

class AreaListActionInProgress extends AreaListState {}

class AreaListSuccess extends AreaListState {
  final String message;
  AreaListSuccess({required this.message});
}

class AreaListError extends AreaListState {
  final String message;
  AreaListError({required this.message});
}
