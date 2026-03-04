/// @archivo   IntentoServicioPrueba_test.dart
/// @descripcion Valida manejo de intento duplicado y recuperacion de intento existente.
/// @modulo    test/Servicios
/// @autor     EvalPro
/// @fecha     2026-03-04

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movil/Constantes/ApiEndpoints.dart';
import 'package:movil/Modelos/Enums/EstadoIntento.dart';
import 'package:movil/Servicios/IntentoServicio.dart';

import '../Auxiliares/ApiServicioSimulado.dart';

void main() {
  test('iniciar retorna intento existente cuando backend responde INTENTO_DUPLICADO con datos', () async {
    final servicio = IntentoServicio(
      ApiServicioSimulado(
        alPublicar: (ruta, _) async {
          expect(ruta, ApiEndpoints.intentos);
          throw DioException(
            requestOptions: RequestOptions(path: ruta),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: ruta),
              statusCode: 409,
              data: <String, dynamic>{
                'codigoError': 'INTENTO_DUPLICADO',
                'datos': <String, dynamic>{
                  'intentoExistente': <String, dynamic>{
                    'id': 'intento-existente-1',
                    'estado': 'EN_PROGRESO',
                    'semillaPersonal': 123,
                    'sesionId': 'sesion-1',
                  },
                },
              },
            ),
          );
        },
      ),
    );

    final intento = await servicio.iniciar('sesion-1', 'ABCD-1234');

    expect(intento.id, 'intento-existente-1');
    expect(intento.estado, EstadoIntento.EN_PROGRESO);
    expect(intento.semillaPersonal, 123);
    expect(intento.sesionId, 'sesion-1');
  });

  test('iniciar relanza error cuando INTENTO_DUPLICADO no incluye intentoExistente', () async {
    final servicio = IntentoServicio(
      ApiServicioSimulado(
        alPublicar: (ruta, _) async {
          throw DioException(
            requestOptions: RequestOptions(path: ruta),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: ruta),
              statusCode: 409,
              data: <String, dynamic>{
                'codigoError': 'INTENTO_DUPLICADO',
                'datos': <String, dynamic>{},
              },
            ),
          );
        },
      ),
    );

    expect(
      () => servicio.iniciar('sesion-1', 'ABCD-1234'),
      throwsA(isA<DioException>()),
    );
  });
}
