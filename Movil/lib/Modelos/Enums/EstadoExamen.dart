/// @archivo   EstadoExamen.dart
/// @descripcion Enumera el ciclo de vida de publicacion de un examen.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum EstadoExamen {
  BORRADOR,
  PUBLICADO,
  ARCHIVADO,
}

/// Utilidades de conversion para EstadoExamen.
extension EstadoExamenTransformador on EstadoExamen {
  /// Convierte nombre textual al enum local.
  static EstadoExamen desdeNombre(String valor) {
    return EstadoExamen.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoExamen.BORRADOR,
    );
  }
}
