/// @archivo   TipoEventoTelemetria.dart
/// @descripcion Enumera eventos registrados para trazabilidad y anti-trampa.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum TipoEventoTelemetria {
  INICIO_EXAMEN,
  CAMBIO_PREGUNTA,
  RESPUESTA_GUARDADA,
  APLICACION_EN_SEGUNDO_PLANO,
  PANTALLA_ABANDONADA,
  CAPTURA_BLOQUEADA,
  FORZAR_CIERRE,
  SESION_INVALIDA,
  EXAMEN_ENVIADO,
  SINCRONIZACION_COMPLETADA,
  SYNC_ANOMALA,
  CAMBIO_RED,
  CAPTURA_PANTALLA_DETECTADA,
  MULTIPLES_DISPOSITIVOS,
}

/// Utilidades de conversion para TipoEventoTelemetria.
extension TipoEventoTelemetriaTransformador on TipoEventoTelemetria {
  /// Convierte nombre textual al enum local.
  static TipoEventoTelemetria desdeNombre(String valor) {
    return TipoEventoTelemetria.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => TipoEventoTelemetria.RESPUESTA_GUARDADA,
    );
  }
}
