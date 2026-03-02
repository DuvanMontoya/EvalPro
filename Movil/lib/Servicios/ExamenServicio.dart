/// @archivo   ExamenServicio.dart
/// @descripcion Obtiene examenes del backend para intentos activos y parsea su estructura.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/Examen.dart';
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
}
