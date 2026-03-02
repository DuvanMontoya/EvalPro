/// @archivo   MapeadorErroresNegocioPrueba_test.dart
/// @descripcion Comprueba el mapeo de errores API/estado a mensajes funcionales.
/// @modulo    test/Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Utilidades/MapeadorErroresNegocio.dart';

void main() {
  test('mapea codigo SESION_NO_ACTIVA al mensaje esperado', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/sesiones/buscar'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/sesiones/buscar'),
        statusCode: 409,
        data: <String, dynamic>{
          'codigoError': 'SESION_NO_ACTIVA',
        },
      ),
    );

    final mensaje = MapeadorErroresNegocio.mapear(error);
    expect(mensaje, Textos.errorSesionNoActiva);
  });

  test('usa mensaje de StateError cuando existe', () {
    final mensaje = MapeadorErroresNegocio.mapear(
      StateError(Textos.errorSoloEstudiantes),
      mensajePorDefecto: Textos.errorGeneral,
    );
    expect(mensaje, Textos.errorSoloEstudiantes);
  });

  test('retorna mensaje por defecto cuando no puede mapear', () {
    final mensaje = MapeadorErroresNegocio.mapear(
      Exception('fallo inesperado'),
      mensajePorDefecto: Textos.errorBusquedaSesion,
    );
    expect(mensaje, Textos.errorBusquedaSesion);
  });
}
