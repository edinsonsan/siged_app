import 'package:equatable/equatable.dart';
import 'package:siged_app/domain/models/documento_adjunto_model.dart';
import 'area.dart';
import 'user.dart';

enum TramiteEstado { recibido, enProceso, observado, finalizado }

class TramiteModel extends Equatable {
  final num id;
  final String cut;
  final String asunto;
  final String remitenteNombre;
  final DateTime fechaCreacion;
  final Area? areaActual;
  final TramiteEstado estado;
  final User? creadoPor;

  final String? remitenteDniRuc;
  final String? remitenteDireccion;
  final String? remitenteTelefono;
  final String? remitenteEmail;

  final List<DocumentoAdjuntoModel> documentosAdjuntos;

  const TramiteModel({
    required this.id,
    required this.cut,
    required this.asunto,
    required this.remitenteNombre,
    required this.fechaCreacion,
    this.areaActual,
    required this.estado,
    this.creadoPor,
    this.remitenteDniRuc = '',
    this.remitenteDireccion = '',
    this.remitenteTelefono = '',
    this.remitenteEmail = '',
    this.documentosAdjuntos = const [],
  });

  factory TramiteModel.fromJson(Map<String, dynamic> json) {
    TramiteEstado parseEstado(String? value) {
      switch (value) {
        case 'RECIBIDO':
          return TramiteEstado.recibido;
        case 'EN_PROCESO':
          return TramiteEstado.enProceso;
        case 'OBSERVADO':
          return TramiteEstado.observado;
        case 'FINALIZADO':
          return TramiteEstado.finalizado;
        default:
          return TramiteEstado.recibido;
      }
    }

    final List<dynamic> docsJson =
        json['documentosAdjuntos'] as List<dynamic>? ?? [];
    final documentos =
        docsJson
            .map(
              (e) => DocumentoAdjuntoModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();

    return TramiteModel(
      id: json['id'] as num,
      cut: json['cut'] as String? ?? json['CUT'] as String? ?? '',
      asunto: json['asunto'] as String? ?? '',
      remitenteNombre:
          (json['remitenteNombre'] ??
                  json['remitenteNombre'] ??
                  json['remitenteNombreCompleto'])
              as String? ??
          '',
      // fechaCreacion: (json['fechaCreacion'] ?? json['fecha_creacion'] ?? json['created_at']) as String? ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? ''),
      areaActual:
          json['areaActual'] is Map<String, dynamic>
              ? Area.fromJson(json['areaActual'] as Map<String, dynamic>)
              : (json['area'] is Map<String, dynamic>
                  ? Area.fromJson(json['area'] as Map<String, dynamic>)
                  : null),
      estado: parseEstado(json['estado'] as String?),
      creadoPor:
          json['creadoPor'] is Map<String, dynamic>
              ? User.fromJson(json['creadoPor'] as Map<String, dynamic>)
              : null,

      remitenteDniRuc: json['remitenteDniRuc'] as String? ?? '',
      remitenteDireccion: json['remitenteDireccion'] as String? ?? '',
      remitenteTelefono: json['remitenteTelefono'] as String? ?? '',
      remitenteEmail: json['remitenteEmail'] as String? ?? '',

      documentosAdjuntos: documentos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cut': cut,
      'asunto': asunto,
      'remitenteNombre': remitenteNombre,
      'fechaCreacion': fechaCreacion,
      if (areaActual != null) 'area_actual': areaActual!.toJson(),
      'estado': () {
        switch (estado) {
          case TramiteEstado.recibido:
            return 'RECIBIDO';
          case TramiteEstado.enProceso:
            return 'EN_PROCESO';
          case TramiteEstado.observado:
            return 'OBSERVADO';
          case TramiteEstado.finalizado:
            return 'FINALIZADO';
        }
      }(),
      if (creadoPor != null) 'creado_por': creadoPor!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    cut,
    asunto,
    remitenteNombre,
    fechaCreacion,
    areaActual,
    estado,
    creadoPor,
    remitenteDniRuc,
    remitenteDireccion,
    remitenteTelefono,
    remitenteEmail,
    documentosAdjuntos,
  ];
}
