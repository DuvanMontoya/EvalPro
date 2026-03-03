/// @archivo   ReporteServicio.dart
/// @descripcion Consume reportes agregados por sesion para panel movil de gestion.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/ReporteEstudianteGestion.dart';
import '../Modelos/ReporteSesionGestion.dart';
import 'ApiServicio.dart';

class ReporteServicio {
  final ApiServicio _apiServicio;

  ReporteServicio(this._apiServicio);

  /// Obtiene reporte detallado de una sesion.
  Future<ReporteSesionGestion> obtenerReporteSesion(String idSesion) {
    return _apiServicio.obtener<ReporteSesionGestion>(
      ApiEndpoints.reporteSesion(idSesion),
      (valor) => ReporteSesionGestion.fromJson(valor as Map<String, dynamic>),
    );
  }

  /// Obtiene historial de intentos para un estudiante.
  Future<ReporteEstudianteGestion> obtenerReporteEstudiante(
      String idEstudiante) {
    return _apiServicio.obtener<ReporteEstudianteGestion>(
      ApiEndpoints.reporteEstudiante(idEstudiante),
      (valor) =>
          ReporteEstudianteGestion.fromJson(valor as Map<String, dynamic>),
    );
  }
}
