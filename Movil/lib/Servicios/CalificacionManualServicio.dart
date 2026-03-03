/// @archivo   CalificacionManualServicio.dart
/// @descripcion Gestiona listado y registro de calificacion manual de respuestas abiertas.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/RespuestaPendienteCalificacion.dart';
import 'ApiServicio.dart';

class CalificacionManualServicio {
  final ApiServicio _apiServicio;

  CalificacionManualServicio(this._apiServicio);

  /// Obtiene respuestas abiertas pendientes de calificacion.
  Future<List<RespuestaPendienteCalificacion>> listarPendientes() {
    return _apiServicio.obtener<List<RespuestaPendienteCalificacion>>(
      ApiEndpoints.respuestasPendientesCalificacion,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => RespuestaPendienteCalificacion.fromJson(
              dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Registra calificacion manual de una respuesta.
  Future<Map<String, dynamic>> calificar({
    required String idRespuesta,
    required double puntajeObtenido,
    String? observacion,
  }) {
    return _apiServicio.actualizar<Map<String, dynamic>>(
      ApiEndpoints.calificarRespuestaManual(idRespuesta),
      (valor) => valor as Map<String, dynamic>,
      cuerpo: <String, dynamic>{
        'puntajeObtenido': puntajeObtenido,
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      },
    );
  }
}
