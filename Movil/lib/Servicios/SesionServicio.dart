/// @archivo   SesionServicio.dart
/// @descripcion Consulta sesiones por codigo para habilitar el flujo de union del estudiante.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/SesionExamen.dart';
import 'ApiServicio.dart';

class SesionServicio {
  final ApiServicio _apiServicio;

  SesionServicio(this._apiServicio);

  /// Busca una sesion por codigo de acceso.
  Future<SesionExamen> buscarPorCodigo(String codigo) {
    final ruta = '${ApiEndpoints.sesionesBuscar}/$codigo';
    return _apiServicio.obtener<SesionExamen>(
      ruta,
      (valor) => SesionExamen.fromJson(valor as Map<String, dynamic>),
    );
  }
}
