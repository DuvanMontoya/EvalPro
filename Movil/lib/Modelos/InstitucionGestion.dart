/// @archivo   InstitucionGestion.dart
/// @descripcion Modela instituciones para panel movil de gestion.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoInstitucion.dart';

class InstitucionGestion {
  final String id;
  final String nombre;
  final String? dominio;
  final EstadoInstitucion estado;
  final DateTime? fechaCreacion;

  const InstitucionGestion({
    required this.id,
    required this.nombre,
    required this.dominio,
    required this.estado,
    required this.fechaCreacion,
  });

  factory InstitucionGestion.fromJson(Map<String, dynamic> json) {
    return InstitucionGestion(
      id: json['id'] as String,
      nombre: (json['nombre'] as String?) ?? '',
      dominio: json['dominio'] as String?,
      estado: EstadoInstitucionTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'ACTIVA'),
      fechaCreacion: _parsearFecha(json['fechaCreacion']),
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
