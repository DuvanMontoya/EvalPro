/// @archivo   SocketServicioPrueba_test.dart
/// @descripcion Valida namespace y autenticacion de handshake del servicio Socket.IO.
/// @modulo    test/Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter_test/flutter_test.dart';

import 'package:movil/Servicios/SocketServicio.dart';

void main() {
  test('construirUrlNamespaceSesiones agrega /sesiones cuando falta', () {
    final resultado =
        SocketServicio.construirUrlNamespaceSesiones('http://localhost:3001');
    expect(resultado, 'http://localhost:3001/sesiones');
  });

  test('construirUrlNamespaceSesiones no duplica /sesiones', () {
    final resultado = SocketServicio.construirUrlNamespaceSesiones(
      'http://localhost:3001/sesiones',
    );
    expect(resultado, 'http://localhost:3001/sesiones');
  });

  test('construirAutenticacionHandshake incluye token y tokenAcceso', () {
    final resultado =
        SocketServicio.construirAutenticacionHandshake('token-prueba');
    expect(resultado['token'], 'token-prueba');
    expect(resultado['tokenAcceso'], 'token-prueba');
  });
}
