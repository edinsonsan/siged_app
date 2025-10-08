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
  final List<AreaCount> areaCounts;
  final TiemposRespuesta tiempos;

  const DashboardLoaded({required this.areaCounts, required this.tiempos});

  @override
  List<Object?> get props => [areaCounts, tiempos];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
