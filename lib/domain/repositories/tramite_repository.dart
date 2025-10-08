import '../../core/services/http_service.dart';
import '../models/tramite_model.dart';

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
