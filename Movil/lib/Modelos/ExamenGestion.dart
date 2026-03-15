/// @archivo   ExamenGestion.dart
/// @descripcion Modela examenes visibles en panel movil de docente/administrador.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoExamen.dart';
import 'Enums/ModalidadExamen.dart';

class ExamenGestion {
  final String id;
  final String titulo;
  final EstadoExamen estado;
  final ModalidadExamen modalidad;
  final int totalPreguntas;
  final double puntajeMaximo;

  const ExamenGestion({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.modalidad,
    required this.totalPreguntas,
    required this.puntajeMaximo,
  });

  /// Construye examen desde payload de API.
  factory ExamenGestion.fromJson(Map<String, dynamic> json) {
    return ExamenGestion(
      id: json['id'] as String,
      titulo: (json['titulo'] as String?) ?? 'Sin titulo',
      estado: EstadoExamenTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'BORRADOR'),
      modalidad: ModalidadExamenTransformador.desdeNombre(
          (json['modalidad'] as String?) ?? 'CONTENIDO_COMPLETO'),
      totalPreguntas: (json['totalPreguntas'] as num?)?.toInt() ?? 0,
      puntajeMaximo: (json['puntajeMaximo'] as num?)?.toDouble() ??
          (json['puntajeMaximoDefinido'] as num?)?.toDouble() ??
          0,
    );
  }
}
