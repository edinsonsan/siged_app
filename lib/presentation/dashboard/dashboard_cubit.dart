import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/report_models.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  DashboardCubit(this.repository) : super(const DashboardLoading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final areaCounts = await repository.getTramitesPorArea();
      final tiempos = await repository.getTiemposRespuesta();
      emit(DashboardLoaded(areaCounts: areaCounts, tiempos: tiempos));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
