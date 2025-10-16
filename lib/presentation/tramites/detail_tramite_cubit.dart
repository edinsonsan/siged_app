import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/tramite_model.dart';
import '../../domain/models/historial_tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';

part 'detail_tramite_state.dart';

class DetailTramiteCubit extends Cubit<DetailTramiteState> {
  final TramiteRepository repository;

  DetailTramiteCubit(this.repository) : super(DetailTramiteInitial());
  Future<void> loadTramiteById(num id) async {
    emit(DetailTramiteLoading());
    try {
      final tramite = await repository.getTramiteById(id);
      final historial = await repository.getHistorial(id);
      emit(DetailTramiteLoaded(tramite: tramite, historial: historial));
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }

  /// Clear any transient success message on the loaded state to avoid repeat snackbars.
  void clearSuccessMessage() {
    final current = state;
    if (current is DetailTramiteLoaded && current.successMessage != null) {
      emit(current.copyWith(successMessage: null));
    }
  }

  Future<void> derivar(num id, int toAreaId, {int? userId}) async {
    emit(DetailTramiteActionInProgress());
    try {
      await repository.derivarTramite(id, toAreaId, userId: userId);
      // reload entire tramite and historial from server by id to ensure fresh data
      await loadTramiteById(id);
      // if loaded, attach a transient success message so the UI can show a snackbar
      final current = state;
      if (current is DetailTramiteLoaded) {
        emit(current.copyWith(successMessage: 'Trámite derivado'));
      }
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }

  Future<void> finalizar(num id, int userId) async {
    emit(DetailTramiteActionInProgress());
    try {
      await repository.finalizeTramite(id, userId: userId);
      await loadTramiteById(id);
      final current = state;
      if (current is DetailTramiteLoaded) {
        emit(current.copyWith(successMessage: 'Trámite finalizado'));
      }
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }

  Future<void> observar(num id, String comment, int userId) async {
    emit(DetailTramiteActionInProgress());
    try {
      await repository.observeTramite(id, comment, userId: userId);
      await loadTramiteById(id);
      final current = state;
      if (current is DetailTramiteLoaded) {
        emit(current.copyWith(successMessage: 'Observación añadida'));
      }
    } catch (e) {
      emit(DetailTramiteError(message: e.toString()));
    }
  }
}
