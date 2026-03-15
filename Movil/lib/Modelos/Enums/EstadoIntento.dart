/// @archivo   EstadoIntento.dart
/// @descripcion Define los estados canonicos del intento de examen.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum EstadoIntento {
  INICIADO,
  BLOQUEADO,
  REANUDADO,
  SUSPENDIDO,
  FINALIZADO_PROVISIONAL,
  ENVIADO,
  ANULADO,
}

/// Utilidades de conversion para EstadoIntento.
extension EstadoIntentoTransformador on EstadoIntento {
  /// Convierte nombre textual al enum local.
  static EstadoIntento desdeNombre(String valor) {
    switch (valor) {
      case 'EN_PROGRESO':
        return EstadoIntento.INICIADO;
      case 'SINCRONIZACION_PENDIENTE':
        return EstadoIntento.FINALIZADO_PROVISIONAL;
      default:
        break;
    }
    return EstadoIntento.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoIntento.INICIADO,
    );
  }
}
