import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/area.dart';
import '../../domain/repositories/admin_repository.dart';

part 'area_list_state.dart';

class AreaListCubit extends Cubit<AreaListState> {
  final AdminRepository repository;
  AreaListCubit(this.repository) : super(AreaListInitial());

  Future<void> loadAreas() async {
    emit(AreaListLoading());
    try {
      final areas = await repository.getAreas();
      emit(AreaListLoaded(areas: areas));
    } catch (e) {
      emit(AreaListError(message: e.toString()));
    }
  }

  Future<void> createArea(Map<String, dynamic> dto) async {
    emit(AreaListActionInProgress());
    try {
      await repository.createArea(dto);
      await loadAreas();
    } catch (e) {
      emit(AreaListError(message: e.toString()));
    }
  }

  Future<void> updateArea(num id, Map<String, dynamic> dto) async {
    emit(AreaListActionInProgress());
    try {
      await repository.updateArea(id, dto);
      await loadAreas();
    } catch (e) {
      emit(AreaListError(message: e.toString()));
    }
  }

  Future<void> deleteArea(num id) async {
    emit(AreaListActionInProgress());
    try {
      await repository.deleteArea(id);
      await loadAreas();
    } catch (e) {
      emit(AreaListError(message: e.toString()));
    }
  }
}
