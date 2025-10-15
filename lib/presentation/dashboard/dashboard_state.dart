part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();

  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardState {
  final List<AreaStatusCount> areaCounts;
  final TiemposRespuesta tiempos;
  final List<ReporteUsuarioModel> userActivity; 

  const DashboardLoaded({required this.areaCounts, required this.tiempos, required this.userActivity});

  @override
  List<Object?> get props => [areaCounts, tiempos, userActivity];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
