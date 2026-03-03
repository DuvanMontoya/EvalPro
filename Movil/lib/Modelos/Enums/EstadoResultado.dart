/// @archivo   EstadoResultado.dart
/// @descripcion Enumera estados del resultado de intento.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-03

enum EstadoResultado {
  PRELIMINAR,
  OFICIAL,
  EN_RECLAMO,
  RECTIFICADO,
}

/// Utilidades de conversion para EstadoResultado.
extension EstadoResultadoTransformador on EstadoResultado {
  /// Convierte nombre textual al enum local.
  static EstadoResultado desdeNombre(String valor) {
    return EstadoResultado.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoResultado.PRELIMINAR,
    );
  }
}
