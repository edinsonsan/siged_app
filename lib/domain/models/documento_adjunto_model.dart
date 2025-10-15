import 'package:equatable/equatable.dart';

class DocumentoAdjuntoModel extends Equatable {
  final num id;
  final String urlArchivo;
  final String tipo;
  final DateTime fechaSubida;

  const DocumentoAdjuntoModel({
    required this.id,
    required this.urlArchivo,
    required this.tipo,
    required this.fechaSubida,
  });

  factory DocumentoAdjuntoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoAdjuntoModel(
      id: json['id'] as num,
      // Nota: El backend usa 'url_archivo', debemos usar el mismo nombre aquí
      urlArchivo: json['url_archivo'] as String? ?? '', 
      tipo: json['tipo'] as String? ?? 'OTRO',
      // Parsear la fecha de subida
      fechaSubida: DateTime.parse(json['fecha_subida'] as String? ?? json['fechaSubida'] as String? ?? ''), 
    );
  }

  @override
  List<Object?> get props => [id, urlArchivo, tipo, fechaSubida];
}