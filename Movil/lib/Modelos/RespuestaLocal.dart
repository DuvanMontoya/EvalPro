/// @archivo   RespuestaLocal.dart
/// @descripcion Representa una respuesta local en memoria o persistida en Drift.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

class RespuestaLocal {
  final String id;
  final String idIntento;
  final String idPregunta;
  final String? valorTexto;
  final List<String> opcionesSeleccionadas;
  final int? tiempoRespuesta;
  final DateTime fechaRespuesta;
  final bool esSincronizada;
  final int reintentosSincronizacion;

  const RespuestaLocal({
    required this.id,
    required this.idIntento,
    required this.idPregunta,
    this.valorTexto,
    required this.opcionesSeleccionadas,
    this.tiempoRespuesta,
    required this.fechaRespuesta,
    required this.esSincronizada,
    required this.reintentosSincronizacion,
  });

  /// Crea una respuesta local desde JSON.
  factory RespuestaLocal.fromJson(Map<String, dynamic> json) {
    return RespuestaLocal(
      id: json['id'] as String,
      idIntento: json['idIntento'] as String,
      idPregunta: json['idPregunta'] as String,
      valorTexto: json['valorTexto'] as String?,
      opcionesSeleccionadas:
          (json['opcionesSeleccionadas'] as List<dynamic>? ?? <dynamic>[])
              .map((dato) => dato as String)
              .toList(),
      tiempoRespuesta: (json['tiempoRespuesta'] as num?)?.toInt(),
      fechaRespuesta: DateTime.parse(json['fechaRespuesta'] as String),
      esSincronizada: (json['esSincronizada'] as bool?) ?? false,
      reintentosSincronizacion:
          (json['reintentosSincronizacion'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convierte la respuesta local a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'idIntento': idIntento,
      'idPregunta': idPregunta,
      'valorTexto': valorTexto,
      'opcionesSeleccionadas': opcionesSeleccionadas,
      'tiempoRespuesta': tiempoRespuesta,
      'fechaRespuesta': fechaRespuesta.toIso8601String(),
      'esSincronizada': esSincronizada,
      'reintentosSincronizacion': reintentosSincronizacion,
    };
  }

  /// Retorna copia con campos opcionales actualizados.
  RespuestaLocal copyWith({
    String? id,
    String? idIntento,
    String? idPregunta,
    String? valorTexto,
    List<String>? opcionesSeleccionadas,
    int? tiempoRespuesta,
    DateTime? fechaRespuesta,
    bool? esSincronizada,
    int? reintentosSincronizacion,
  }) {
    return RespuestaLocal(
      id: id ?? this.id,
      idIntento: idIntento ?? this.idIntento,
      idPregunta: idPregunta ?? this.idPregunta,
      valorTexto: valorTexto ?? this.valorTexto,
      opcionesSeleccionadas:
          opcionesSeleccionadas ?? this.opcionesSeleccionadas,
      tiempoRespuesta: tiempoRespuesta ?? this.tiempoRespuesta,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      esSincronizada: esSincronizada ?? this.esSincronizada,
      reintentosSincronizacion:
          reintentosSincronizacion ?? this.reintentosSincronizacion,
    );
  }
}
