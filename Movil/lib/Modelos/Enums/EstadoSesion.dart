/// @archivo   EstadoSesion.dart
/// @descripcion Enumera estados operativos de una sesion de examen.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum EstadoSesion {
  PENDIENTE,
  ACTIVA,
  FINALIZADA,
  CANCELADA,
}

/// Utilidades de conversion para EstadoSesion.
extension EstadoSesionTransformador on EstadoSesion {
  /// Convierte nombre textual al enum local.
  static EstadoSesion desdeNombre(String valor) {
    return EstadoSesion.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoSesion.PENDIENTE,
    );
  }
}
