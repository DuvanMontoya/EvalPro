/// @archivo   ValidadoresAutenticacion.dart
/// @descripcion Centraliza validaciones del formulario de autenticacion.
/// @modulo    Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-03

/// Validaciones para acceso seguro en login.
abstract class ValidadoresAutenticacion {
  static final RegExp _expresionCorreo = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  /// Valida formato minimo de correo.
  static String? validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';
    if (correo.isEmpty) {
      return 'Ingresa un correo institucional';
    }
    if (!_expresionCorreo.hasMatch(correo)) {
      return 'Ingresa un correo valido';
    }
    return null;
  }

  /// Valida longitud minima de contrasena.
  static String? validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu contrasena';
    }
    if (valor.length < 8) {
      return 'Minimo 8 caracteres';
    }
    return null;
  }
}
