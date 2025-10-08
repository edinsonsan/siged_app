import 'package:equatable/equatable.dart';
import 'user.dart';

class HistorialTramiteModel extends Equatable {
  final num id;
  final String comentario;
  final String fecha;
  final User? usuario;

  const HistorialTramiteModel({required this.id, required this.comentario, required this.fecha, this.usuario});

  factory HistorialTramiteModel.fromJson(Map<String, dynamic> json) {
    return HistorialTramiteModel(
      id: json['id'] as num,
      comentario: json['comentario'] as String? ?? json['comment'] as String? ?? '',
      fecha: json['fecha'] as String? ?? json['created_at'] as String? ?? '',
      usuario: json['usuario'] is Map<String, dynamic> ? User.fromJson(json['usuario'] as Map<String, dynamic>) : null,
    );
  }

  @override
  List<Object?> get props => [id, comentario, fecha, usuario];
}
