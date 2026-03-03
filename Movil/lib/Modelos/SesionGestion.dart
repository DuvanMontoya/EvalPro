/// @archivo   SesionGestion.dart
/// @descripcion Modela sesiones para panel de gestion docente/administrativa.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoSesion.dart';

class SesionGestion {
  final String id;
  final String? codigoAcceso;
  final EstadoSesion estado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String examenId;
  final String? descripcion;

  const SesionGestion({
    required this.id,
    required this.codigoAcceso,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    required this.examenId,
    required this.descripcion,
  });

  /// Construye una sesion de gestion desde JSON.
  factory SesionGestion.fromJson(Map<String, dynamic> json) {
    return SesionGestion(
      id: json['id'] as String,
      codigoAcceso: json['codigoAcceso'] as String?,
      estado: EstadoSesionTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'PENDIENTE'),
      fechaInicio: _parsearFecha(json['fechaInicio']),
      fechaFin: _parsearFecha(json['fechaFin']),
      examenId: (json['examenId'] as String?) ?? '',
      descripcion: json['descripcion'] as String?,
    );
  }

  static DateTime? _parsearFecha(Object? valor) {
    final texto = valor as String?;
    if (texto == null || texto.isEmpty) {
      return null;
    }
    return DateTime.tryParse(texto);
  }
}
