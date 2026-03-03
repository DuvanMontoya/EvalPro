/// @archivo   ValidadoresAutenticacion_test.dart
/// @descripcion Cubre reglas de validacion de correo y contrasena para login.
/// @modulo    test/Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter_test/flutter_test.dart';
import 'package:movil/Utilidades/ValidadoresAutenticacion.dart';

void main() {
  group('ValidadoresAutenticacion.validarCorreo', () {
    test('retorna error cuando el correo esta vacio', () {
      expect(
        ValidadoresAutenticacion.validarCorreo('   '),
        'Ingresa un correo institucional',
      );
    });

    test('retorna error cuando el correo no tiene formato valido', () {
      expect(
        ValidadoresAutenticacion.validarCorreo('correo-sin-arroba'),
        'Ingresa un correo valido',
      );
    });

    test('acepta correos validos institucionales', () {
      expect(
        ValidadoresAutenticacion.validarCorreo('docente@evalpro.edu'),
        isNull,
      );
    });
  });

  group('ValidadoresAutenticacion.validarContrasena', () {
    test('retorna error cuando la contrasena esta vacia', () {
      expect(
        ValidadoresAutenticacion.validarContrasena(''),
        'Ingresa tu contrasena',
      );
    });

    test('retorna error cuando la contrasena es corta', () {
      expect(
        ValidadoresAutenticacion.validarContrasena('abc123'),
        'Minimo 8 caracteres',
      );
    });

    test('acepta contrasena de longitud valida', () {
      expect(
        ValidadoresAutenticacion.validarContrasena('Segura123!'),
        isNull,
      );
    });
  });
}
