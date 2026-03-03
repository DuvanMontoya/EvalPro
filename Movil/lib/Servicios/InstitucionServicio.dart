/// @archivo   InstitucionServicio.dart
/// @descripcion Gestiona instituciones para panel movil de superadministrador.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/Enums/EstadoInstitucion.dart';
import '../Modelos/InstitucionGestion.dart';
import 'ApiServicio.dart';

class InstitucionServicio {
  final ApiServicio _apiServicio;

  InstitucionServicio(this._apiServicio);

  /// Lista instituciones visibles para el actor autenticado.
  Future<List<InstitucionGestion>> listar() {
    return _apiServicio.obtener<List<InstitucionGestion>>(
      ApiEndpoints.instituciones,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) =>
              InstitucionGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Crea una nueva institucion.
  Future<InstitucionGestion> crear({
    required String nombre,
    String? dominio,
  }) {
    return _apiServicio.publicar<InstitucionGestion>(
      ApiEndpoints.instituciones,
      (valor) => InstitucionGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'nombre': nombre,
        if (dominio != null && dominio.trim().isNotEmpty)
          'dominio': dominio.trim(),
      },
    );
  }

  /// Actualiza el estado de una institucion.
  Future<InstitucionGestion> cambiarEstado({
    required String idInstitucion,
    required EstadoInstitucion estado,
    required String razon,
  }) {
    return _apiServicio.actualizar<InstitucionGestion>(
      ApiEndpoints.estadoInstitucion(idInstitucion),
      (valor) => InstitucionGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'estado': estado.name,
        'razon': razon.trim(),
      },
    );
  }
}
