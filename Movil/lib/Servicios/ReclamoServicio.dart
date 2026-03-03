/// @archivo   ReclamoServicio.dart
/// @descripcion Gestiona creacion y resolucion de reclamos de calificacion.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/ReclamoGestion.dart';
import 'ApiServicio.dart';

class ReclamoServicio {
  final ApiServicio _apiServicio;

  ReclamoServicio(this._apiServicio);

  /// Lista reclamos visibles para docente/administrador/superadministrador.
  Future<List<ReclamoGestion>> listar() {
    return _apiServicio.obtener<List<ReclamoGestion>>(
      ApiEndpoints.reclamos,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => ReclamoGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Crea reclamo asociado a un resultado de intento.
  Future<ReclamoGestion> crear({
    required String idResultado,
    required String motivo,
    String? idPregunta,
  }) {
    return _apiServicio.publicar<ReclamoGestion>(
      ApiEndpoints.crearReclamo(idResultado),
      (valor) => ReclamoGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'motivo': motivo.trim(),
        if (idPregunta != null && idPregunta.trim().isNotEmpty)
          'idPregunta': idPregunta.trim(),
      },
    );
  }

  /// Resuelve reclamo por actor autorizado.
  Future<ReclamoGestion> resolver({
    required String idReclamo,
    required bool aprobar,
    required String resolucion,
    double? puntajeNuevo,
  }) {
    return _apiServicio.actualizar<ReclamoGestion>(
      ApiEndpoints.resolverReclamo(idReclamo),
      (valor) => ReclamoGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'aprobar': aprobar,
        'resolucion': resolucion.trim(),
        if (puntajeNuevo != null) 'puntajeNuevo': puntajeNuevo,
      },
    );
  }
}
