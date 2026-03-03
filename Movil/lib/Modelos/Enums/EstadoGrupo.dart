/// @archivo   EstadoGrupo.dart
/// @descripcion Enumera estados del grupo academico.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-03

enum EstadoGrupo {
  BORRADOR,
  ACTIVO,
  CERRADO,
  ARCHIVADO,
}

/// Utilidades de conversion para EstadoGrupo.
extension EstadoGrupoTransformador on EstadoGrupo {
  /// Convierte nombre textual al enum local.
  static EstadoGrupo desdeNombre(String valor) {
    return EstadoGrupo.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => EstadoGrupo.BORRADOR,
    );
  }
}
