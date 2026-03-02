/// @archivo   EstadoIntento.dart
/// @descripcion Define estados del intento de examen durante sincronizacion y envio.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum EstadoIntento {
  EN_PROGRESO,
  ENVIADO,
  ANULADO,
  SINCRONIZACION_PENDIENTE,
}

/// Utilidades de conversion para EstadoIntento.
extension EstadoIntentoTransformador on EstadoIntento {
  /// Convierte nombre textual al enum local.
  static EstadoIntento desdeNombre(String valor) {
    return EstadoIntento.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoIntento.EN_PROGRESO,
    );
  }
}
