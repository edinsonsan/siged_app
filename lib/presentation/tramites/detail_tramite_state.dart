part of 'detail_tramite_cubit.dart';

abstract class DetailTramiteState {}

class DetailTramiteInitial extends DetailTramiteState {}

class DetailTramiteLoading extends DetailTramiteState {}

class DetailTramiteLoaded extends DetailTramiteState with EquatableMixin {
  final TramiteModel tramite;
  final List<HistorialTramiteModel> historial;
  final String? successMessage;

  DetailTramiteLoaded({required this.tramite, required this.historial, this.successMessage});

  DetailTramiteLoaded copyWith({TramiteModel? tramite, List<HistorialTramiteModel>? historial, String? successMessage}) {
    return DetailTramiteLoaded(
      tramite: tramite ?? this.tramite,
      historial: historial ?? this.historial,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [tramite, historial, successMessage];
}

class DetailTramiteActionInProgress extends DetailTramiteState {}

class DetailTramiteError extends DetailTramiteState {
  final String message;
  DetailTramiteError({required this.message});
}
