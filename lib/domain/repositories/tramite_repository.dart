import '../../core/services/http_service.dart';
import '../models/tramite_model.dart';
import '../models/historial_tramite_model.dart';

class TramiteFilter {
  final int? areaId;
  final String? estado;
  final String? cut;
  final int? limit;
  final int? offset;

  TramiteFilter({this.areaId, this.estado, this.cut, this.limit, this.offset});

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> q = {};
    if (areaId != null) q['areaId'] = areaId;
    if (estado != null) q['estado'] = estado;
    if (cut != null) q['cut'] = cut;
    if (limit != null) q['limit'] = limit;
    if (offset != null) q['offset'] = offset;
    return q;
  }
}

class TramiteRepository {
  final DioHttpService http;

  TramiteRepository(this.http);

  Future<void> derivarTramite(num id, int toAreaId, {int? userId}) async {
    await http.post('/tramites/\$id/derivar'.replaceAll('\$id', id.toString()), data: {'toAreaId': toAreaId, 'userId': userId});
  }

  Future<void> finalizeTramite(num id, {int? userId}) async {
    await http.post('/tramites/\$id/finalize'.replaceAll('\$id', id.toString()), data: {'userId': userId});
  }

  Future<void> observeTramite(num id, String comment, {int? userId}) async {
    await http.post('/tramites/\$id/observe'.replaceAll('\$id', id.toString()), data: {'userId': userId, 'comment': comment});
  }

  Future<List<HistorialTramiteModel>> getHistorial(num tramiteId) async {
    final res = await http.get('/tramites/\$tramiteId/historial'.replaceAll('\$tramiteId', tramiteId.toString()));
    final data = res.data;
    if (data is List) {
      return data.map((e) => HistorialTramiteModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => HistorialTramiteModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Fetch tramites with optional filters. Returns a tuple: (list, total)
  Future<Map<String, dynamic>> getTramites({required TramiteFilter filters}) async {
    final res = await http.get('/tramites', queryParameters: filters.toQueryParameters());
    final data = res.data;
    List<TramiteModel> list = [];
    int total = 0;
    if (data is List) {
      list = data.map((e) => TramiteModel.fromJson(e as Map<String, dynamic>)).toList();
      total = list.length;
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        list = (data['data'] as List).map((e) => TramiteModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (data['total'] != null) {
        total = (data['total'] is int) ? data['total'] as int : int.tryParse('${data['total']}') ?? list.length;
      } else {
        total = list.length;
      }
    }

    return {'list': list, 'total': total};
  }
}
