/// @archivo   Usuario.dart
/// @descripcion Representa el usuario autenticado sin datos sensibles.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Enums/RolUsuario.dart';

class Usuario {
  final String id;
  final String nombre;
  final String apellidos;
  final String correo;
  final RolUsuario rol;
  final bool activo;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.rol,
    required this.activo,
  });

  /// Construye un usuario desde el JSON de la API.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      correo: json['correo'] as String,
      rol: RolUsuarioTransformador.desdeNombre(json['rol'] as String),
      activo: (json['activo'] as bool?) ?? true,
    );
  }

  /// Serializa el modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'rol': rol.name,
      'activo': activo,
    };
  }
}
