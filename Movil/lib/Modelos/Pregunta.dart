/// @archivo   Pregunta.dart
/// @descripcion Define la estructura de una pregunta con sus opciones.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Enums/TipoPregunta.dart';
import 'OpcionRespuesta.dart';

class Pregunta {
  final String id;
  final String enunciado;
  final TipoPregunta tipo;
  final int orden;
  final double puntaje;
  final int? tiempoSugerido;
  final String? imagenUrl;
  final List<OpcionRespuesta> opciones;

  const Pregunta({
    required this.id,
    required this.enunciado,
    required this.tipo,
    required this.orden,
    required this.puntaje,
    this.tiempoSugerido,
    this.imagenUrl,
    required this.opciones,
  });

  /// Construye una pregunta desde JSON.
  factory Pregunta.fromJson(Map<String, dynamic> json) {
    final listaOpciones = (json['opciones'] as List<dynamic>? ?? <dynamic>[])
        .map((dato) => OpcionRespuesta.fromJson(dato as Map<String, dynamic>))
        .toList();

    return Pregunta(
      id: json['id'] as String,
      enunciado: json['enunciado'] as String,
      tipo: TipoPreguntaTransformador.desdeNombre(json['tipo'] as String),
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      puntaje: (json['puntaje'] as num?)?.toDouble() ?? 0,
      tiempoSugerido: (json['tiempoSugerido'] as num?)?.toInt(),
      imagenUrl: json['imagenUrl'] as String?,
      opciones: listaOpciones,
    );
  }

  /// Convierte la pregunta a mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'enunciado': enunciado,
      'tipo': tipo.name,
      'orden': orden,
      'puntaje': puntaje,
      'tiempoSugerido': tiempoSugerido,
      'imagenUrl': imagenUrl,
      'opciones': opciones.map((opcion) => opcion.toJson()).toList(),
    };
  }

  /// Crea una copia de la pregunta.
  Pregunta copyWith({
    String? id,
    String? enunciado,
    TipoPregunta? tipo,
    int? orden,
    double? puntaje,
    int? tiempoSugerido,
    String? imagenUrl,
    List<OpcionRespuesta>? opciones,
  }) {
    return Pregunta(
      id: id ?? this.id,
      enunciado: enunciado ?? this.enunciado,
      tipo: tipo ?? this.tipo,
      orden: orden ?? this.orden,
      puntaje: puntaje ?? this.puntaje,
      tiempoSugerido: tiempoSugerido ?? this.tiempoSugerido,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      opciones: opciones ?? this.opciones,
    );
  }
}
