/// @archivo   EventoTelemetria.dart
/// @descripcion Modela un evento de telemetria asociado a un intento de examen.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Enums/TipoEventoTelemetria.dart';

class EventoTelemetria {
  final String id;
  final String idIntento;
  final TipoEventoTelemetria tipo;
  final String? descripcion;
  final Map<String, dynamic>? metadatos;
  final int? numeroPregunta;
  final int? tiempoTranscurrido;
  final DateTime fechaEvento;

  const EventoTelemetria({
    required this.id,
    required this.idIntento,
    required this.tipo,
    this.descripcion,
    this.metadatos,
    this.numeroPregunta,
    this.tiempoTranscurrido,
    required this.fechaEvento,
  });

  /// Crea un evento desde un objeto JSON.
  factory EventoTelemetria.fromJson(Map<String, dynamic> json) {
    final metadatos = json['metadatos'];
    return EventoTelemetria(
      id: json['id'] as String,
      idIntento: json['idIntento'] as String,
      tipo:
          TipoEventoTelemetriaTransformador.desdeNombre(json['tipo'] as String),
      descripcion: json['descripcion'] as String?,
      metadatos: metadatos is Map<String, dynamic> ? metadatos : null,
      numeroPregunta: (json['numeroPregunta'] as num?)?.toInt(),
      tiempoTranscurrido: (json['tiempoTranscurrido'] as num?)?.toInt(),
      fechaEvento: DateTime.parse(json['fechaEvento'] as String),
    );
  }

  /// Convierte el evento a formato JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'idIntento': idIntento,
      'tipo': tipo.name,
      'descripcion': descripcion,
      'metadatos': metadatos,
      'numeroPregunta': numeroPregunta,
      'tiempoTranscurrido': tiempoTranscurrido,
      'fechaEvento': fechaEvento.toIso8601String(),
    };
  }
}
