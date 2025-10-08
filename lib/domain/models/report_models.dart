class AreaCount {
  final String nombre;
  final int count;

  AreaCount({required this.nombre, required this.count});

  factory AreaCount.fromJson(Map<String, dynamic> json) {
    // Try to read a few common shapes
    final nombre = (json['nombre'] ?? json['area'] ?? json['name'] ?? json['area_nombre']) as String? ?? json['area_name'] as String? ?? '';
    final countVal = json['count'] ?? json['cantidad'] ?? json['total'] ?? json['value'];
    final count = (countVal is int) ? countVal : (int.tryParse('${countVal ?? 0}') ?? 0);
    return AreaCount(nombre: nombre, count: count);
  }
}

class TiemposRespuesta {
  final double averageTime; // in days
  final Map<String, dynamic> raw;

  TiemposRespuesta({required this.averageTime, required this.raw});

  factory TiemposRespuesta.fromJson(Map<String, dynamic> json) {
    // Look for common keys
    double avg = 0.0;
    if (json.containsKey('average') || json.containsKey('average_time') || json.containsKey('avg')) {
      final v = json['average'] ?? json['average_time'] ?? json['avg'];
      avg = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    } else if (json.containsKey('days')) {
      final v = json['days'];
      avg = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    }
    return TiemposRespuesta(averageTime: avg, raw: json);
  }
}
