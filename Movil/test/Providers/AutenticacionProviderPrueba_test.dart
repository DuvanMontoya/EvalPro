/// @archivo   AutenticacionProviderPrueba_test.dart
/// @descripcion Cubre carga inicial y errores de inicio de sesion del provider de autenticacion.
/// @modulo    test/Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Modelos/Enums/RolUsuario.dart';
import 'package:movil/Modelos/SesionAutenticada.dart';
import 'package:movil/Modelos/Usuario.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';
import 'package:movil/Servicios/AutenticacionServicio.dart';

import '../Auxiliares/ApiServicioSimulado.dart';

void main() {
  test('build carga sesion activa persistida', () async {
    final usuario = _crearUsuario(RolUsuario.ESTUDIANTE);
    final container = ProviderContainer(
      overrides: <Override>[
        autenticacionServicioProvider.overrideWith(
          (ref) => _AutenticacionServicioSimulado(
            alTieneSesionActiva: () async => true,
            alObtenerUsuarioActual: () async => usuario,
            alIniciarSesion: (_, __) async => _crearSesion(usuario),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final suscripcion = container.listen(
      autenticacionEstadoProvider,
      (_, __) {},
    );
    addTearDown(suscripcion.close);
    for (var intento = 0; intento < 10; intento++) {
      if (container.read(autenticacionEstadoProvider).inicializado) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    final estado = container.read(autenticacionEstadoProvider);

    expect(estado.inicializado, isTrue);
    expect(estado.estaAutenticado, isTrue);
    expect(estado.usuario?.id, usuario.id);
  });

  test('iniciarSesion mapea error de SIN_PERMISOS', () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/autenticacion/iniciar-sesion'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/autenticacion/iniciar-sesion'),
        statusCode: 403,
        data: <String, dynamic>{'codigoError': 'SIN_PERMISOS'},
      ),
    );
    final container = ProviderContainer(
      overrides: <Override>[
        autenticacionServicioProvider.overrideWith(
          (ref) => _AutenticacionServicioSimulado(
            alTieneSesionActiva: () async => false,
            alObtenerUsuarioActual: () async => null,
            alIniciarSesion: (_, __) async => throw error,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(autenticacionEstadoProvider.notifier).iniciarSesion(
          correo: 'admin@evalpro.com',
          contrasena: 'Segura123!',
        );
    final estado = container.read(autenticacionEstadoProvider);

    expect(estado.estaAutenticado, isFalse);
    expect(estado.error, Textos.errorSinPermisos);
  });
}

class _AutenticacionServicioSimulado extends AutenticacionServicio {
  final Future<bool> Function() _alTieneSesionActiva;
  final Future<Usuario?> Function() _alObtenerUsuarioActual;
  final Future<SesionAutenticada> Function(String, String) _alIniciarSesion;

  _AutenticacionServicioSimulado({
    required Future<bool> Function() alTieneSesionActiva,
    required Future<Usuario?> Function() alObtenerUsuarioActual,
    required Future<SesionAutenticada> Function(String, String) alIniciarSesion,
  })  : _alTieneSesionActiva = alTieneSesionActiva,
        _alObtenerUsuarioActual = alObtenerUsuarioActual,
        _alIniciarSesion = alIniciarSesion,
        super(
          apiServicio: ApiServicioSimulado(),
          almacenSeguro: const FlutterSecureStorage(),
        );

  @override
  Future<bool> tieneSesionActiva() => _alTieneSesionActiva();

  @override
  Future<Usuario?> obtenerUsuarioActual() => _alObtenerUsuarioActual();

  @override
  Future<SesionAutenticada> iniciarSesion({
    required String correo,
    required String contrasena,
  }) {
    return _alIniciarSesion(correo, contrasena);
  }
}

Usuario _crearUsuario(RolUsuario rol) {
  return Usuario(
    id: 'usuario-prueba',
    nombre: 'Estudiante',
    apellidos: 'Prueba',
    correo: 'estudiante@evalpro.com',
    rol: rol,
    activo: true,
  );
}

SesionAutenticada _crearSesion(Usuario usuario) {
  return SesionAutenticada(
    tokenAcceso: 'token-acceso',
    tokenRefresh: 'token-refresh',
    usuario: usuario,
  );
}
