import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';

part 'tramite_state.dart';

class TramiteCubit extends Cubit<TramiteState> {
  final TramiteRepository repository;
  TramiteFilter currentFilter = TramiteFilter(limit: 10, offset: 0);
  bool showAll = false;

  TramiteCubit(this.repository) : super(const TramiteLoading()) {
    fetchPage();
  }

  Future<void> fetchPage({TramiteFilter? filter}) async {
    emit(const TramiteLoading());
    if (filter != null) currentFilter = filter;
    try {
      // Respect showAll: if showAll is true, send a filter without areaId
      final effectiveFilter = showAll ? TramiteFilter(limit: currentFilter.limit, offset: currentFilter.offset, estado: currentFilter.estado, cut: currentFilter.cut) : currentFilter;
      final res = await repository.getTramites(filters: effectiveFilter);
      final list = (res['list'] as List<TramiteModel>?) ?? [];
      final total = (res['total'] as int?) ?? list.length;
      emit(TramiteLoaded(list: list, total: total, filter: currentFilter));
    } catch (e) {
      emit(TramiteError(e.toString()));
    }
  }

  void setShowAll(bool value) {
    showAll = value;
    // when toggling, refresh the list and reset pagination
    currentFilter = TramiteFilter(limit: currentFilter.limit, offset: 0, estado: currentFilter.estado, cut: currentFilter.cut, areaId: showAll ? null : currentFilter.areaId);
    fetchPage();
  }

  Future<void> changePage(int limit, int offset) async {
    currentFilter = TramiteFilter(areaId: currentFilter.areaId, estado: currentFilter.estado, cut: currentFilter.cut, limit: limit, offset: offset);
    await fetchPage();
  }

  Future<void> applySearch(String? cutOrAsunto) async {
    currentFilter = TramiteFilter(areaId: currentFilter.areaId, estado: currentFilter.estado, cut: cutOrAsunto, limit: currentFilter.limit, offset: 0);
    await fetchPage();
  }

  Future<void> applyEstado(String? estado) async {
    currentFilter = TramiteFilter(areaId: currentFilter.areaId, estado: estado, cut: currentFilter.cut, limit: currentFilter.limit, offset: 0);
    await fetchPage();
  }
}
