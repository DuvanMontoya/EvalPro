/// @archivo   SesionExamen.dart
/// @descripcion Representa una sesion consultada por codigo para un estudiante.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Enums/EstadoSesion.dart';
import 'Enums/ModalidadExamen.dart';

class ResumenExamenSesion {
  final String id;
  final String titulo;
  final ModalidadExamen modalidad;
  final int duracionMinutos;
  final String? docente;

  const ResumenExamenSesion({
    required this.id,
    required this.titulo,
    required this.modalidad,
    required this.duracionMinutos,
    this.docente,
  });

  /// Construye el resumen desde JSON.
  factory ResumenExamenSesion.fromJson(Map<String, dynamic> json) {
    return ResumenExamenSesion(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      modalidad:
          ModalidadExamenTransformador.desdeNombre(json['modalidad'] as String),
      duracionMinutos: (json['duracionMinutos'] as num?)?.toInt() ?? 0,
      docente: json['docente'] as String?,
    );
  }

  /// Serializa el resumen a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'modalidad': modalidad.name,
      'duracionMinutos': duracionMinutos,
      'docente': docente,
    };
  }
}

class SesionExamen {
  final String id;
  final String codigoAcceso;
  final EstadoSesion estado;
  final int semillaGrupo;
  final ResumenExamenSesion examen;

  const SesionExamen({
    required this.id,
    required this.codigoAcceso,
    required this.estado,
    required this.semillaGrupo,
    required this.examen,
  });

  /// Construye una sesion desde la API.
  factory SesionExamen.fromJson(Map<String, dynamic> json) {
    final examenJson =
        (json['examen'] as Map<String, dynamic>? ?? <String, dynamic>{});
    return SesionExamen(
      id: json['id'] as String,
      codigoAcceso: json['codigoAcceso'] as String,
      estado: EstadoSesionTransformador.desdeNombre(json['estado'] as String),
      semillaGrupo: (json['semillaGrupo'] as num?)?.toInt() ?? 1,
      examen: ResumenExamenSesion.fromJson(examenJson),
    );
  }

  /// Convierte la sesion a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'codigoAcceso': codigoAcceso,
      'estado': estado.name,
      'semillaGrupo': semillaGrupo,
      'examen': examen.toJson(),
    };
  }
}
