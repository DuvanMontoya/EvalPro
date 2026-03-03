/// @archivo   PeriodoGestionServicio.dart
/// @descripcion Gestiona periodos academicos para administracion movil.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/PeriodoGestion.dart';
import 'ApiServicio.dart';

class PeriodoGestionServicio {
  final ApiServicio _apiServicio;

  PeriodoGestionServicio(this._apiServicio);

  /// Lista periodos visibles para el rol autenticado.
  Future<List<PeriodoGestion>> listar() {
    return _apiServicio.obtener<List<PeriodoGestion>>(
      ApiEndpoints.periodos,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => PeriodoGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Crea un periodo academico.
  Future<PeriodoGestion> crear({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required bool activo,
    String? idInstitucion,
  }) {
    return _apiServicio.publicar<PeriodoGestion>(
      ApiEndpoints.periodos,
      (valor) => PeriodoGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'nombre': nombre.trim(),
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'activo': activo,
        if (idInstitucion != null && idInstitucion.trim().isNotEmpty)
          'idInstitucion': idInstitucion.trim(),
      },
    );
  }

  /// Actualiza estado activo de un periodo.
  Future<PeriodoGestion> actualizarEstado({
    required String idPeriodo,
    required bool activo,
  }) {
    return _apiServicio.actualizar<PeriodoGestion>(
      ApiEndpoints.estadoPeriodo(idPeriodo),
      (valor) => PeriodoGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'activo': activo,
      },
    );
  }
}
