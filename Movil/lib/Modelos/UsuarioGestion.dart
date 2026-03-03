/// @archivo   UsuarioGestion.dart
/// @descripcion Modela usuarios de gestion para app movil multirol.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/RolUsuario.dart';

class UsuarioGestion {
  final String id;
  final String? idInstitucion;
  final String nombre;
  final String apellidos;
  final String correo;
  final RolUsuario rol;
  final String estadoCuenta;
  final bool activo;
  final bool primerLogin;
  final String? credencialTemporalPlano;

  const UsuarioGestion({
    required this.id,
    required this.idInstitucion,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.rol,
    required this.estadoCuenta,
    required this.activo,
    required this.primerLogin,
    required this.credencialTemporalPlano,
  });

  factory UsuarioGestion.fromJson(Map<String, dynamic> json) {
    return UsuarioGestion(
      id: json['id'] as String,
      idInstitucion: json['idInstitucion'] as String?,
      nombre: (json['nombre'] as String?) ?? '',
      apellidos: (json['apellidos'] as String?) ?? '',
      correo: (json['correo'] as String?) ?? '',
      rol: RolUsuarioTransformador.desdeNombre(
          (json['rol'] as String?) ?? 'ESTUDIANTE'),
      estadoCuenta: (json['estadoCuenta'] as String?) ?? 'ACTIVO',
      activo: (json['activo'] as bool?) ?? true,
      primerLogin: (json['primerLogin'] as bool?) ?? false,
      credencialTemporalPlano: json['credencialTemporalPlano'] as String?,
    );
  }
}
