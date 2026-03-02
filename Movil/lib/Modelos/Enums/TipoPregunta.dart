/// @archivo   TipoPregunta.dart
/// @descripcion Enumera tipos de pregunta compatibles con el flujo de examen.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum TipoPregunta {
  OPCION_MULTIPLE,
  SELECCION_MULTIPLE,
  RESPUESTA_ABIERTA,
  VERDADERO_FALSO,
}

/// Utilidades de conversion para TipoPregunta.
extension TipoPreguntaTransformador on TipoPregunta {
  /// Convierte nombre textual del backend al enum local.
  static TipoPregunta desdeNombre(String valor) {
    return TipoPregunta.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => TipoPregunta.OPCION_MULTIPLE,
    );
  }
}
