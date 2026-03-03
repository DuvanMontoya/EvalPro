/// @archivo   UsuarioGestionServicio.dart
/// @descripcion Gestiona operaciones CRUD de usuarios desde app movil administrativa.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-03

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/Enums/RolUsuario.dart';
import '../Modelos/UsuarioGestion.dart';
import 'ApiServicio.dart';

class UsuarioGestionServicio {
  final ApiServicio _apiServicio;

  UsuarioGestionServicio(this._apiServicio);

  /// Lista usuarios visibles para el actor autenticado.
  Future<List<UsuarioGestion>> listar() {
    return _apiServicio.obtener<List<UsuarioGestion>>(
      ApiEndpoints.usuarios,
      (valor) => (valor as List<dynamic>? ?? <dynamic>[])
          .map((dato) => UsuarioGestion.fromJson(dato as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Crea un usuario con rol y contraseña temporal.
  Future<UsuarioGestion> crear({
    required String nombre,
    required String apellidos,
    required String correo,
    required String contrasena,
    required RolUsuario rol,
    String? idInstitucion,
  }) {
    return _apiServicio.publicar<UsuarioGestion>(
      ApiEndpoints.usuarios,
      (valor) => UsuarioGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'nombre': nombre.trim(),
        'apellidos': apellidos.trim(),
        'correo': correo.trim(),
        'contrasena': contrasena,
        'rol': rol.name,
        if (idInstitucion != null && idInstitucion.trim().isNotEmpty)
          'idInstitucion': idInstitucion.trim(),
      },
    );
  }

  /// Actualiza parcialmente un usuario.
  Future<UsuarioGestion> actualizar({
    required String idUsuario,
    String? nombre,
    String? apellidos,
    String? correo,
    RolUsuario? rol,
    String? contrasena,
  }) {
    final cuerpo = <String, dynamic>{};
    if (nombre != null && nombre.trim().isNotEmpty) {
      cuerpo['nombre'] = nombre.trim();
    }
    if (apellidos != null && apellidos.trim().isNotEmpty) {
      cuerpo['apellidos'] = apellidos.trim();
    }
    if (correo != null && correo.trim().isNotEmpty) {
      cuerpo['correo'] = correo.trim();
    }
    if (rol != null) {
      cuerpo['rol'] = rol.name;
    }
    if (contrasena != null && contrasena.isNotEmpty) {
      cuerpo['contrasena'] = contrasena;
    }

    return _apiServicio.actualizar<UsuarioGestion>(
      ApiEndpoints.usuarioPorId(idUsuario),
      (valor) => UsuarioGestion.fromJson(valor as Map<String, dynamic>),
      cuerpo: cuerpo,
    );
  }

  /// Desactiva un usuario en backend.
  Future<UsuarioGestion> desactivar(String idUsuario) {
    return _apiServicio.eliminar<UsuarioGestion>(
      ApiEndpoints.usuarioPorId(idUsuario),
      (valor) => UsuarioGestion.fromJson(valor as Map<String, dynamic>),
    );
  }
}
