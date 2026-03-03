/// @archivo   GrupoGestionServicio.dart
/// @descripcion Gestiona grupos academicos y sus membresias desde app movil.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/Enums/EstadoGrupo.dart';
import '../Modelos/GrupoGestion.dart';
import 'ApiServicio.dart';

class GrupoGestionServicio {
  final ApiServicio _apiServicio;

  GrupoGestionServicio(this._apiServicio);

  /// Lista grupos visibles para el actor autenticado.
  Future<List<GrupoGestion>> listar() {
    return _apiServicio.obtener<List<GrupoGestion>>(
      ApiEndpoints.grupos,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => GrupoGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Crea un grupo academico en estado BORRADOR.
  Future<GrupoGestion> crear({
    required String nombre,
    String? descripcion,
    required String idPeriodo,
    String? idInstitucion,
  }) {
    return _apiServicio.publicar<GrupoGestion>(
      ApiEndpoints.grupos,
      (valor) => GrupoGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'nombre': nombre.trim(),
        if (descripcion != null && descripcion.trim().isNotEmpty)
          'descripcion': descripcion.trim(),
        'idPeriodo': idPeriodo,
        if (idInstitucion != null && idInstitucion.trim().isNotEmpty)
          'idInstitucion': idInstitucion.trim(),
      },
    );
  }

  /// Asigna un docente a un grupo.
  Future<void> asignarDocente({
    required String idGrupo,
    required String idDocente,
  }) {
    return _apiServicio.publicar<void>(
      ApiEndpoints.asignarDocenteGrupo(idGrupo),
      (_) => null,
      cuerpo: <String, dynamic>{
        'idDocente': idDocente,
      },
    );
  }

  /// Inscribe un estudiante en un grupo.
  Future<void> inscribirEstudiante({
    required String idGrupo,
    required String idEstudiante,
  }) {
    return _apiServicio.publicar<void>(
      ApiEndpoints.inscribirEstudianteGrupo(idGrupo),
      (_) => null,
      cuerpo: <String, dynamic>{
        'idEstudiante': idEstudiante,
      },
    );
  }

  /// Cambia estado de un grupo academico.
  Future<GrupoGestion> cambiarEstado({
    required String idGrupo,
    required EstadoGrupo estado,
    String? razon,
  }) {
    return _apiServicio.actualizar<GrupoGestion>(
      ApiEndpoints.estadoGrupo(idGrupo),
      (valor) => GrupoGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'estado': estado.name,
        if (razon != null && razon.trim().isNotEmpty) 'razon': razon.trim(),
      },
    );
  }
}
