/// @archivo   ModalidadExamen.dart
/// @descripcion Define las modalidades canonicas admitidas para presentar un examen.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum ModalidadExamen {
  CONTENIDO_COMPLETO,
  SOLO_RESPUESTAS,
}

/// Utilidades de conversion para ModalidadExamen.
extension ModalidadExamenTransformador on ModalidadExamen {
  /// Resuelve modalidad desde nombre textual.
  static ModalidadExamen desdeNombre(String valor) {
    switch (valor) {
      case 'DIGITAL_COMPLETO':
        return ModalidadExamen.CONTENIDO_COMPLETO;
      case 'HOJA_RESPUESTAS':
        return ModalidadExamen.SOLO_RESPUESTAS;
      default:
        break;
    }
    return ModalidadExamen.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => ModalidadExamen.CONTENIDO_COMPLETO,
    );
  }
}
