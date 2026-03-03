/// @archivo   EstadoReclamo.dart
/// @descripcion Enumera estados operativos de un reclamo de calificacion.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-03

enum EstadoReclamo {
  PRESENTADO,
  EN_REVISION,
  RESUELTO,
  RECHAZADO,
}

/// Utilidades de conversion para EstadoReclamo.
extension EstadoReclamoTransformador on EstadoReclamo {
  /// Convierte nombre textual al enum local.
  static EstadoReclamo desdeNombre(String valor) {
    return EstadoReclamo.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoReclamo.PRESENTADO,
    );
  }
}
