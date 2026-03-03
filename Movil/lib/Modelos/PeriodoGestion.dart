/// @archivo   PeriodoGestion.dart
/// @descripcion Modela periodos academicos para gestion administrativa movil.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

class PeriodoGestion {
  final String id;
  final String idInstitucion;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;

  const PeriodoGestion({
    required this.id,
    required this.idInstitucion,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
  });

  factory PeriodoGestion.fromJson(Map<String, dynamic> json) {
    return PeriodoGestion(
      id: json['id'] as String,
      idInstitucion: (json['idInstitucion'] as String?) ?? '',
      nombre: (json['nombre'] as String?) ?? '',
      fechaInicio: DateTime.tryParse((json['fechaInicio'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fechaFin: DateTime.tryParse((json['fechaFin'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      activo: (json['activo'] as bool?) ?? false,
    );
  }
}
