/// @archivo   SesionProviderPrueba_test.dart
/// @descripcion Valida estados de busqueda de sesion y estandar de mensajes de negocio.
/// @modulo    test/Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Modelos/Enums/EstadoSesion.dart';
import 'package:movil/Modelos/Enums/ModalidadExamen.dart';
import 'package:movil/Modelos/SesionExamen.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';
import 'package:movil/Providers/SesionProvider.dart';
import 'package:movil/Servicios/SesionServicio.dart';

import '../Auxiliares/ApiServicioSimulado.dart';

void main() {
  test('buscarPorCodigo actualiza sesion cuando el backend responde', () async {
    final sesion = _crearSesionPrueba();
    final container = ProviderContainer(
      overrides: <Override>[
        sesionServicioProvider.overrideWith(
          (ref) => _SesionServicioSimulado(
            alBuscar: (_) async => sesion,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(sesionActualProvider.notifier)
        .buscarPorCodigo('AB12-CD');
    final estado = container.read(sesionActualProvider);

    expect(estado.sesion?.id, sesion.id);
    expect(estado.error, isNull);
    expect(estado.cargando, isFalse);
  });

  test('buscarPorCodigo mapea error de negocio SESION_NO_ACTIVA', () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/sesiones/buscar/AB12-CD'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/sesiones/buscar/AB12-CD'),
        statusCode: 409,
        data: <String, dynamic>{'codigoError': 'SESION_NO_ACTIVA'},
      ),
    );
    final container = ProviderContainer(
      overrides: <Override>[
        sesionServicioProvider.overrideWith(
          (ref) => _SesionServicioSimulado(
            alBuscar: (_) async => throw error,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(sesionActualProvider.notifier)
        .buscarPorCodigo('AB12-CD');
    final estado = container.read(sesionActualProvider);

    expect(estado.sesion, isNull);
    expect(estado.error, Textos.errorSesionNoActiva);
    expect(estado.cargando, isFalse);
  });
}

class _SesionServicioSimulado extends SesionServicio {
  final Future<SesionExamen> Function(String codigo) _alBuscar;

  _SesionServicioSimulado({
    required Future<SesionExamen> Function(String codigo) alBuscar,
  })  : _alBuscar = alBuscar,
        super(ApiServicioSimulado());

  @override
  Future<SesionExamen> buscarPorCodigo(String codigo) => _alBuscar(codigo);
}

SesionExamen _crearSesionPrueba() {
  return SesionExamen(
    id: 'sesion-1',
    codigoAcceso: 'AB12-CD',
    estado: EstadoSesion.ACTIVA,
    semillaGrupo: 12345,
    examen: const ResumenExamenSesion(
      id: 'examen-1',
      titulo: 'Parcial de matematica',
      modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
      duracionMinutos: 60,
      docente: 'Docente Prueba',
    ),
  );
}
