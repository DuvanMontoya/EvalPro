/// @archivo   TipoEventoTelemetria.dart
/// @descripcion Enumera eventos canonicos del ciclo de vida del intento.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum TipoEventoTelemetria {
  EVALUACION_ABIERTA,
  INTENTO_INICIADO,
  RESPUESTA_SELECCIONADA,
  RESPUESTA_CAMBIADA,
  RESPUESTA_LIMPIADA,
  APP_EN_BACKGROUND,
  APP_EN_FOREGROUND,
  INCIDENTE_REGISTRADO,
  REINGRESO_AUTORIZADO,
  TOKEN_REINGRESO_CONSUMIDO,
  ENVIO_SOLICITADO,
  FINALIZACION_PROVISIONAL,
  RECONCILIACION_EXITOSA,
  RECONCILIACION_FALLIDA,
  RESULTADO_PUBLICADO,
  ANULACION,
}

/// Utilidades de conversion para TipoEventoTelemetria.
extension TipoEventoTelemetriaTransformador on TipoEventoTelemetria {
  /// Convierte nombre textual al enum local.
  static TipoEventoTelemetria desdeNombre(String valor) {
    switch (valor) {
      case 'INICIO_EXAMEN':
        return TipoEventoTelemetria.INTENTO_INICIADO;
      case 'CAMBIO_PREGUNTA':
        return TipoEventoTelemetria.EVALUACION_ABIERTA;
      case 'RESPUESTA_GUARDADA':
        return TipoEventoTelemetria.RESPUESTA_SELECCIONADA;
      case 'APLICACION_EN_SEGUNDO_PLANO':
      case 'SEGUNDO_PLANO':
        return TipoEventoTelemetria.APP_EN_BACKGROUND;
      case 'FOCO_RECUPERADO':
        return TipoEventoTelemetria.APP_EN_FOREGROUND;
      case 'EXAMEN_ENVIADO':
        return TipoEventoTelemetria.ENVIO_SOLICITADO;
      case 'SINCRONIZACION_COMPLETADA':
        return TipoEventoTelemetria.RECONCILIACION_EXITOSA;
      case 'SESION_INVALIDA':
      case 'SYNC_ANOMALA':
        return TipoEventoTelemetria.RECONCILIACION_FALLIDA;
      case 'PANTALLA_ABANDONADA':
      case 'ABANDONO_PANTALLA':
      case 'CAPTURA_BLOQUEADA':
      case 'FORZAR_CIERRE':
      case 'CIERRE_FORZADO':
      case 'TIEMPO_ANOMALO':
      case 'CAMBIO_RED':
      case 'CAPTURA_PANTALLA_DETECTADA':
      case 'MULTIPLES_DISPOSITIVOS':
        return TipoEventoTelemetria.INCIDENTE_REGISTRADO;
      default:
        break;
    }
    return TipoEventoTelemetria.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => TipoEventoTelemetria.RESPUESTA_SELECCIONADA,
    );
  }
}
