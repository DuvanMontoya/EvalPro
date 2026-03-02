/// @archivo   RolUsuario.dart
/// @descripcion Enumera los roles de usuario permitidos en EvalPro.
/// @modulo    Modelos/Enums
/// @autor     EvalPro
/// @fecha     2026-03-02

enum RolUsuario {
  ADMINISTRADOR,
  DOCENTE,
  ESTUDIANTE,
}

/// Utilidades para transformar RolUsuario desde y hacia texto.
extension RolUsuarioTransformador on RolUsuario {
  /// Obtiene enum a partir de nombre textual.
  static RolUsuario desdeNombre(String valor) {
    return RolUsuario.values.firstWhere(
      (elemento) => elemento.name == valor,
      orElse: () => RolUsuario.ESTUDIANTE,
    );
  }
}
