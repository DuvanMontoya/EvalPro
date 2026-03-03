/// @archivo   GrupoGestion.dart
/// @descripcion Modela grupos academicos y sus membresias para gestion movil.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoGrupo.dart';

class UsuarioEnGrupo {
  final String id;
  final String nombre;
  final String apellidos;
  final String correo;

  const UsuarioEnGrupo({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
  });

  factory UsuarioEnGrupo.fromJson(Map<String, dynamic> json) {
    return UsuarioEnGrupo(
      id: json['id'] as String,
      nombre: (json['nombre'] as String?) ?? '',
      apellidos: (json['apellidos'] as String?) ?? '',
      correo: (json['correo'] as String?) ?? '',
    );
  }
}

class GrupoGestion {
  final String id;
  final String idInstitucion;
  final String idPeriodo;
  final String nombre;
  final String? descripcion;
  final EstadoGrupo estado;
  final String codigoAcceso;
  final String? nombrePeriodo;
  final bool? periodoActivo;
  final List<UsuarioEnGrupo> docentes;
  final List<UsuarioEnGrupo> estudiantes;

  const GrupoGestion({
    required this.id,
    required this.idInstitucion,
    required this.idPeriodo,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    required this.codigoAcceso,
    required this.nombrePeriodo,
    required this.periodoActivo,
    required this.docentes,
    required this.estudiantes,
  });

  factory GrupoGestion.fromJson(Map<String, dynamic> json) {
    final periodo = json['periodo'] as Map<String, dynamic>?;
    final docentesJson = (json['docentes'] as List<dynamic>? ?? <dynamic>[])
        .map((dato) => (dato as Map<String, dynamic>)['docente'])
        .whereType<Map<String, dynamic>>()
        .map(UsuarioEnGrupo.fromJson)
        .toList();
    final estudiantesJson =
        (json['estudiantes'] as List<dynamic>? ?? <dynamic>[])
            .map((dato) => (dato as Map<String, dynamic>)['estudiante'])
            .whereType<Map<String, dynamic>>()
            .map(UsuarioEnGrupo.fromJson)
            .toList();

    return GrupoGestion(
      id: json['id'] as String,
      idInstitucion: (json['idInstitucion'] as String?) ?? '',
      idPeriodo: (json['idPeriodo'] as String?) ?? '',
      nombre: (json['nombre'] as String?) ?? '',
      descripcion: json['descripcion'] as String?,
      estado: EstadoGrupoTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'BORRADOR'),
      codigoAcceso: (json['codigoAcceso'] as String?) ?? '',
      nombrePeriodo: periodo?['nombre'] as String?,
      periodoActivo: periodo?['activo'] as bool?,
      docentes: docentesJson,
      estudiantes: estudiantesJson,
    );
  }
}
