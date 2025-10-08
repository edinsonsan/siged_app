import 'package:equatable/equatable.dart';

/// Immutable Area model
class Area extends Equatable {
  final num id;
  final String nombre;
  final String? descripcion;

  const Area({required this.id, required this.nombre, this.descripcion});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as num,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] != null ? json['descripcion'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }

  @override
  List<Object?> get props => [id, nombre, descripcion];
}
