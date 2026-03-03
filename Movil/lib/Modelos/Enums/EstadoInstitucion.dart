/// @archivo   EstadoInstitucion.dart
/// @descripcion Enumera estados de una institucion en el backend.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-03

enum EstadoInstitucion {
  ACTIVA,
  SUSPENDIDA,
  ARCHIVADA,
}

/// Utilidades de conversion para EstadoInstitucion.
extension EstadoInstitucionTransformador on EstadoInstitucion {
  /// Convierte nombre textual al enum local.
  static EstadoInstitucion desdeNombre(String valor) {
    return EstadoInstitucion.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoInstitucion.ACTIVA,
    );
  }
}
