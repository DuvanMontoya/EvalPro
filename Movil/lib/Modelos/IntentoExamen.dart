/// @archivo   IntentoExamen.dart
/// @descripcion Modela el intento activo de un estudiante dentro de una sesion.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Enums/EstadoIntento.dart';

class IntentoExamen {
  final String id;
  final EstadoIntento estado;
  final int semillaPersonal;
  final String sesionId;

  const IntentoExamen({
    required this.id,
    required this.estado,
    required this.semillaPersonal,
    required this.sesionId,
  });

  /// Crea el intento desde JSON.
  factory IntentoExamen.fromJson(Map<String, dynamic> json) {
    return IntentoExamen(
      id: json['id'] as String,
      estado: EstadoIntentoTransformador.desdeNombre(json['estado'] as String),
      semillaPersonal: (json['semillaPersonal'] as num?)?.toInt() ?? 1,
      sesionId: json['sesionId'] as String,
    );
  }

  /// Convierte el intento a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'estado': estado.name,
      'semillaPersonal': semillaPersonal,
      'sesionId': sesionId,
    };
  }
}
