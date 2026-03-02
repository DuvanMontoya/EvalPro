/// @archivo   ModalidadExamen.dart
/// @descripcion Define modalidades admitidas para presentar un examen.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum ModalidadExamen {
  DIGITAL_COMPLETO,
  HOJA_RESPUESTAS,
}

/// Utilidades de conversion para ModalidadExamen.
extension ModalidadExamenTransformador on ModalidadExamen {
  /// Resuelve modalidad desde nombre textual.
  static ModalidadExamen desdeNombre(String valor) {
    return ModalidadExamen.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => ModalidadExamen.DIGITAL_COMPLETO,
    );
  }
}
