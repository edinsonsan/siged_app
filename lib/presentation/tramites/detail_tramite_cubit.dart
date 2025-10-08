import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/tramite_model.dart';
import '../../domain/models/historial_tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';

part 'detail_tramite_state.dart';

class DetailTramiteCubit extends Cubit<DetailTramiteState> {
  final TramiteRepository repository;

  DetailTramiteCubit(this.repository) : super(DetailTramiteInitial());

  Future<void> loadTramite(TramiteModel tramite) async {
    emit(DetailTramiteLoading());
    try {
      // In many APIs, a full detalle endpoint exists; for now we use the provided tramite and fetch historial.
      final historial = await repository.getHistorial(tramite.id);
      emit(DetailTramiteLoaded(tramite: tramite, historial: historial));
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }

  Future<void> derivar(num id, int toAreaId, {int? userId}) async {
    emit(DetailTramiteActionInProgress());
    try {
      await repository.derivarTramite(id, toAreaId, userId: userId);
      // refresh historial
      final current = state;
      if (current is DetailTramiteLoaded) {
        final historial = await repository.getHistorial(current.tramite.id);
        emit(current.copyWith(historial: historial));
      } else {
        emit(DetailTramiteSuccess(message: 'Trámite derivado'));
      }
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }

  Future<void> finalizar(num id, {int? userId}) async {
    emit(DetailTramiteActionInProgress());
    try {
      await repository.finalizeTramite(id, userId: userId);
      final current = state;
      if (current is DetailTramiteLoaded) {
        final historial = await repository.getHistorial(current.tramite.id);
        emit(current.copyWith(historial: historial));
      } else {
        emit(DetailTramiteSuccess(message: 'Trámite finalizado'));
      }
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }

  Future<void> observar(num id, String comment, {int? userId}) async {
    emit(DetailTramiteActionInProgress());
    try {
      await repository.observeTramite(id, comment, userId: userId);
      final current = state;
      if (current is DetailTramiteLoaded) {
        final historial = await repository.getHistorial(current.tramite.id);
        emit(current.copyWith(historial: historial));
      } else {
        emit(DetailTramiteSuccess(message: 'Observación añadida'));
      }
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }
}
