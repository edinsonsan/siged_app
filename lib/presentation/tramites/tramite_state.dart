part of 'tramite_cubit.dart';

abstract class TramiteState extends Equatable {
  const TramiteState();
}

class TramiteLoading extends TramiteState {
  const TramiteLoading();

  @override
  List<Object?> get props => [];
}

class TramiteLoaded extends TramiteState {
  final List<TramiteModel> list;
  final int total;
  final TramiteFilter filter;

  const TramiteLoaded({required this.list, required this.total, required this.filter});

  @override
  List<Object?> get props => [list, total, filter];
}

class TramiteError extends TramiteState {
  final String message;
  const TramiteError(this.message);

  @override
  List<Object?> get props => [message];
}
