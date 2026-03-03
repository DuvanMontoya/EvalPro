/// @archivo   ReclamoGestion.dart
/// @descripcion Modela reclamos de calificacion para estudiantes y gestion.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoReclamo.dart';

class ResumenPersona {
  final String id;
  final String nombre;
  final String apellidos;
  final String correo;

  const ResumenPersona({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
  });

  factory ResumenPersona.fromJson(Map<String, dynamic> json) {
    return ResumenPersona(
      id: (json['id'] as String?) ?? '',
      nombre: (json['nombre'] as String?) ?? '',
      apellidos: (json['apellidos'] as String?) ?? '',
      correo: (json['correo'] as String?) ?? '',
    );
  }
}

class ReclamoGestion {
  final String id;
  final String resultadoId;
  final String? idPregunta;
  final String motivo;
  final EstadoReclamo estado;
  final DateTime? presentadoEn;
  final DateTime? resolverEn;
  final String? resolucion;
  final double? puntajeAnterior;
  final double? puntajeNuevo;
  final String? idIntento;
  final String? idSesion;
  final String? codigoSesion;
  final String? tituloExamen;
  final ResumenPersona? estudiante;
  final ResumenPersona? resueltoPor;

  const ReclamoGestion({
    required this.id,
    required this.resultadoId,
    required this.idPregunta,
    required this.motivo,
    required this.estado,
    required this.presentadoEn,
    required this.resolverEn,
    required this.resolucion,
    required this.puntajeAnterior,
    required this.puntajeNuevo,
    required this.idIntento,
    required this.idSesion,
    required this.codigoSesion,
    required this.tituloExamen,
    required this.estudiante,
    required this.resueltoPor,
  });

  factory ReclamoGestion.fromJson(Map<String, dynamic> json) {
    final sesion = json['sesion'] as Map<String, dynamic>?;
    final examen = sesion?['examen'] as Map<String, dynamic>?;
    final intento = json['intento'] as Map<String, dynamic>?;
    return ReclamoGestion(
      id: json['id'] as String,
      resultadoId: (json['resultadoId'] as String?) ??
          (json['resultado'] as Map<String, dynamic>? ??
              <String, dynamic>{})['id'] as String? ??
          '',
      idPregunta: json['idPregunta'] as String?,
      motivo: (json['motivo'] as String?) ?? '',
      estado: EstadoReclamoTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'PRESENTADO'),
      presentadoEn: _parsearFecha(json['presentadoEn']),
      resolverEn: _parsearFecha(json['resolverEn']),
      resolucion: json['resolucion'] as String?,
      puntajeAnterior: (json['puntajeAnterior'] as num?)?.toDouble(),
      puntajeNuevo: (json['puntajeNuevo'] as num?)?.toDouble(),
      idIntento: intento?['id'] as String?,
      idSesion: sesion?['id'] as String?,
      codigoSesion: sesion?['codigoAcceso'] as String?,
      tituloExamen: examen?['titulo'] as String?,
      estudiante: (json['estudiante'] as Map<String, dynamic>?) != null
          ? ResumenPersona.fromJson(json['estudiante'] as Map<String, dynamic>)
          : null,
      resueltoPor: (json['resueltoPor'] as Map<String, dynamic>?) != null
          ? ResumenPersona.fromJson(json['resueltoPor'] as Map<String, dynamic>)
          : null,
    );
  }
}

DateTime? _parsearFecha(Object? valor) {
  final texto = valor as String?;
  if (texto == null || texto.isEmpty) {
    return null;
  }
  return DateTime.tryParse(texto);
}
