/// @archivo   ExamenServicio.dart
/// @descripcion Gestiona examenes para flujo de intento y panel docente/administrativo.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/Examen.dart';
import '../Modelos/ExamenGestion.dart';
import 'ApiServicio.dart';

class ExamenServicio {
  final ApiServicio _apiServicio;

  ExamenServicio(this._apiServicio);

  /// Descarga el examen del intento sin respuestas correctas.
  Future<Examen> obtenerParaIntento(String idIntento) async {
    final respuesta = await _apiServicio.obtener<Map<String, dynamic>>(
      ApiEndpoints.examenPorIntento(idIntento),
      (valor) => valor as Map<String, dynamic>,
    );

    final examenJson = respuesta['examen'] as Map<String, dynamic>;
    return Examen.fromJson(examenJson);
  }

  /// Lista examenes visibles para el usuario autenticado.
  Future<List<ExamenGestion>> listarExamenesGestion() {
    return _apiServicio.obtener<List<ExamenGestion>>(
      ApiEndpoints.examenes,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => ExamenGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Publica un examen en estado borrador.
  Future<ExamenGestion> publicarExamen(String idExamen) {
    return _apiServicio.publicar<ExamenGestion>(
      ApiEndpoints.publicarExamen(idExamen),
      (valor) => ExamenGestion.fromJson(valor as Map<String, dynamic>),
    );
  }

  /// Archiva un examen.
  Future<ExamenGestion> archivarExamen(String idExamen) {
    return _apiServicio.eliminar<ExamenGestion>(
      ApiEndpoints.archivarExamen(idExamen),
      (valor) => ExamenGestion.fromJson(valor as Map<String, dynamic>),
    );
  }
}
