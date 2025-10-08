import 'package:equatable/equatable.dart';

class DocumentoAdjunto extends Equatable {
  final num id;
  final String nombre;
  final String url;
  final String tipo; // e.g., application/pdf

  const DocumentoAdjunto({required this.id, required this.nombre, required this.url, required this.tipo});

  factory DocumentoAdjunto.fromJson(Map<String, dynamic> json) {
    return DocumentoAdjunto(
      id: json['id'] as num,
      nombre: json['nombre'] as String? ?? json['name'] as String? ?? '',
      url: json['url'] as String? ?? json['path'] as String? ?? '',
      tipo: json['tipo'] as String? ?? json['mime'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, nombre, url, tipo];
}
