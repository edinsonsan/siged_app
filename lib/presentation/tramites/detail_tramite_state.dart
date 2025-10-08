part of 'detail_tramite_cubit.dart';

abstract class DetailTramiteState {}

class DetailTramiteInitial extends DetailTramiteState {}

class DetailTramiteLoading extends DetailTramiteState {}

class DetailTramiteLoaded extends DetailTramiteState with EquatableMixin {
  final TramiteModel tramite;
  final List<HistorialTramiteModel> historial;

  DetailTramiteLoaded({required this.tramite, required this.historial});

  DetailTramiteLoaded copyWith({TramiteModel? tramite, List<HistorialTramiteModel>? historial}) {
    return DetailTramiteLoaded(tramite: tramite ?? this.tramite, historial: historial ?? this.historial);
  }

  @override
  List<Object?> get props => [tramite, historial];
}

class DetailTramiteActionInProgress extends DetailTramiteState {}

class DetailTramiteSuccess extends DetailTramiteState {
  final String message;
  DetailTramiteSuccess({required this.message});
}

class DetailTramiteError extends DetailTramiteState {
  final String message;
  DetailTramiteError({required this.message});
}
