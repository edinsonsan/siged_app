import '../../core/services/http_service.dart';
import '../models/report_models.dart';

class DashboardRepository {
  final DioHttpService httpService;

  DashboardRepository(this.httpService);

  Future<List<AreaStatusCount>> getTramitesPorArea() async {
    final res = await httpService.get('/reportes/tramites-por-area');
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => AreaStatusCount.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => AreaStatusCount.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<TiemposRespuesta> getTiemposRespuesta() async {
    final res = await httpService.get('/reportes/tiempos-respuesta');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return TiemposRespuesta.fromJson(data);
    }
    // fallback
    return TiemposRespuesta(averageTime: 0.0, raw: {});
  }

  Future<List<ReporteUsuarioModel>> getTramitesPorUsuario() async {
    final res = await httpService.get('/reportes/tramites-por-usuario');
    final data = res.data;
    if (data is List) {
      return data.map((e) => ReporteUsuarioModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => ReporteUsuarioModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

}
