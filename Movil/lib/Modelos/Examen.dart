/// @archivo   Examen.dart
/// @descripcion Modelo de datos para un examen descargado del backend.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Enums/ModalidadExamen.dart';
import 'Pregunta.dart';

class Examen {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? instrucciones;
  final ModalidadExamen modalidad;
  final int duracionMinutos;
  final bool permitirNavegacion;
  final bool mostrarPuntaje;
  final List<Pregunta> preguntas;

  const Examen({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.instrucciones,
    required this.modalidad,
    required this.duracionMinutos,
    required this.permitirNavegacion,
    required this.mostrarPuntaje,
    required this.preguntas,
  });

  /// Retorna total de preguntas del examen.
  int get totalPreguntas => preguntas.length;

  /// Construye un examen desde JSON.
  factory Examen.fromJson(Map<String, dynamic> json) {
    return Examen(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      instrucciones: json['instrucciones'] as String?,
      modalidad:
          ModalidadExamenTransformador.desdeNombre(json['modalidad'] as String),
      duracionMinutos: (json['duracionMinutos'] as num?)?.toInt() ?? 0,
      permitirNavegacion: (json['permitirNavegacion'] as bool?) ?? false,
      mostrarPuntaje: (json['mostrarPuntaje'] as bool?) ?? false,
      preguntas: (json['preguntas'] as List<dynamic>? ?? <dynamic>[])
          .map((dato) => Pregunta.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte el examen a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'instrucciones': instrucciones,
      'modalidad': modalidad.name,
      'duracionMinutos': duracionMinutos,
      'totalPreguntas': totalPreguntas,
      'permitirNavegacion': permitirNavegacion,
      'mostrarPuntaje': mostrarPuntaje,
      'preguntas': preguntas.map((pregunta) => pregunta.toJson()).toList(),
    };
  }

  /// Retorna copia modificada del examen.
  Examen copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? instrucciones,
    ModalidadExamen? modalidad,
    int? duracionMinutos,
    bool? permitirNavegacion,
    bool? mostrarPuntaje,
    List<Pregunta>? preguntas,
  }) {
    return Examen(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      instrucciones: instrucciones ?? this.instrucciones,
      modalidad: modalidad ?? this.modalidad,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      permitirNavegacion: permitirNavegacion ?? this.permitirNavegacion,
      mostrarPuntaje: mostrarPuntaje ?? this.mostrarPuntaje,
      preguntas: preguntas ?? this.preguntas,
    );
  }
}
