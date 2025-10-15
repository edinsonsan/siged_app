class AreaStatusCount {
  final int? areaId;
  final String areaNombre;
  final int recibido;
  final int enProceso;
  final int finalizado;
  final int observado;
  final int total; // Propiedad calculada para la gráfica o KPI

  AreaStatusCount({
    required this.areaId,
    required this.areaNombre,
    required this.recibido,
    required this.enProceso,
    required this.finalizado,
    required this.observado,
  }) : total = recibido + enProceso + finalizado + observado;

  factory AreaStatusCount.fromJson(Map<String, dynamic> json) {
    // Helper para parsear valores de cadena (raw) a int, usando 0 como default.
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return AreaStatusCount(
      // El backend devuelve 'areaId' y 'areaNombre'
      areaId:
          json['areaId'] != null
              ? int.tryParse(json['areaId'].toString())
              : null,
      areaNombre:
          json['areaNombre'] as String? ??
          'Sin Asignar', // Asignamos un nombre para null
      recibido: parseCount(json['recibido']),
      enProceso: parseCount(json['en_proceso']),
      finalizado: parseCount(json['finalizado']),
      observado: parseCount(json['observado']),
    );
  }
}

class TiemposRespuesta {
  final double averageTime; // in days
  final Map<String, dynamic> raw;

  TiemposRespuesta({required this.averageTime, required this.raw});

  factory TiemposRespuesta.fromJson(Map<String, dynamic> json) {
    // El backend devuelve 'avg_days'. Priorizamos esa clave.
    final avgDays = json['avg_days'] ?? json['average_days'] ?? json['avg'];

    double avg = 0.0;
    if (avgDays != null) {
      avg =
          (avgDays is num)
              ? avgDays.toDouble()
              : double.tryParse('$avgDays') ?? 0.0;
    }

    // Si no se encontró 'avg_days', buscamos en otras claves como fallback,
    // pero idealmente deberías recibir 'avg_days' del backend.
    if (avg == 0.0) {
      final genericAvg = json['average'] ?? json['avg_seconds'];
      if (genericAvg != null) {
        avg =
            (genericAvg is num)
                ? genericAvg.toDouble()
                : double.tryParse('$genericAvg') ?? 0.0;
        // Si el valor es en segundos, lo convertimos a días
        if (json.containsKey('avg_seconds')) {
          avg = avg / (60 * 60 * 24);
        }
      }
    }

    return TiemposRespuesta(averageTime: avg, raw: json);
  }
}

class ReporteUsuarioModel {
  final num userId;
  final String userName;
  final int createdCount;
  final int participatedCount;
  final int totalActivity;

  ReporteUsuarioModel({
    required this.userId,
    required this.userName,
    required this.createdCount,
    required this.participatedCount,
  }) : totalActivity = createdCount + participatedCount;

  factory ReporteUsuarioModel.fromJson(Map<String, dynamic> json) {
    // Helper para parsear valores numéricos
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return ReporteUsuarioModel(
      userId: json['userId'] as num,
      userName: json['userName'] as String? ?? 'Usuario Desconocido',
      createdCount: parseCount(json['createdCount']),
      participatedCount: parseCount(json['participatedCount']),
    );
  }
}
