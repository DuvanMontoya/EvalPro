/// @archivo   SesionServicio.dart
/// @descripcion Gestiona sesiones para flujo de estudiante y panel docente/administrativo.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/SesionGestion.dart';
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

  /// Lista sesiones visibles para el rol autenticado.
  Future<List<SesionGestion>> listarSesionesGestion() {
    return _apiServicio.obtener<List<SesionGestion>>(
      ApiEndpoints.sesiones,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => SesionGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Activa una sesion pendiente (docente propietario).
  Future<SesionGestion> activarSesion(String idSesion) {
    return _apiServicio.publicar<SesionGestion>(
      ApiEndpoints.activarSesion(idSesion),
      (valor) => SesionGestion.fromJson(valor as Map<String, dynamic>),
    );
  }

  /// Finaliza una sesion activa.
  Future<SesionGestion> finalizarSesion(String idSesion) {
    return _apiServicio.publicar<SesionGestion>(
      ApiEndpoints.finalizarSesion(idSesion),
      (valor) => SesionGestion.fromJson(valor as Map<String, dynamic>),
    );
  }

  /// Cancela una sesion pendiente o activa.
  Future<SesionGestion> cancelarSesion(String idSesion) {
    return _apiServicio.publicar<SesionGestion>(
      ApiEndpoints.cancelarSesion(idSesion),
      (valor) => SesionGestion.fromJson(valor as Map<String, dynamic>),
    );
  }
}
