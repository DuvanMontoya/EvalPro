/// @archivo   AutenticacionServicioPrueba_test.dart
/// @descripcion Verifica restricciones de rol y persistencia segura en autenticacion movil.
/// @modulo    test/Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movil/Constantes/ApiEndpoints.dart';
import 'package:movil/Constantes/ClavesAlmacen.dart';
import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Modelos/Enums/RolUsuario.dart';
import 'package:movil/Modelos/SesionAutenticada.dart';
import 'package:movil/Modelos/Usuario.dart';
import 'package:movil/Servicios/AutenticacionServicio.dart';

import '../Auxiliares/ApiServicioSimulado.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canal = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final almacenamientoMemoria = <String, String>{};

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (llamada) async {
      final argumentos = (llamada.arguments as Map<Object?, Object?>?)
          ?.cast<String, Object?>();
      switch (llamada.method) {
        case 'read':
          return almacenamientoMemoria[argumentos?['key'] as String];
        case 'write':
          final clave = argumentos?['key'] as String;
          final valor = argumentos?['value'] as String?;
          if (valor == null) {
            almacenamientoMemoria.remove(clave);
          } else {
            almacenamientoMemoria[clave] = valor;
          }
          return null;
        case 'delete':
          almacenamientoMemoria.remove(argumentos?['key'] as String);
          return null;
        case 'deleteAll':
          almacenamientoMemoria.clear();
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, null);
    almacenamientoMemoria.clear();
  });

  test('iniciarSesion persiste tokens cuando el usuario es estudiante activo',
      () async {
    final servicio = AutenticacionServicio(
      apiServicio: ApiServicioSimulado(
        alPublicar: (ruta, _) async {
          expect(ruta, ApiEndpoints.autenticacionIniciarSesion);
          return _crearSesion(RolUsuario.ESTUDIANTE).toJson();
        },
      ),
      almacenSeguro: const FlutterSecureStorage(),
    );

    final sesion = await servicio.iniciarSesion(
      correo: 'estudiante@evalpro.com',
      contrasena: 'Segura123!',
    );

    expect(sesion.usuario.rol, RolUsuario.ESTUDIANTE);
    expect(
      await const FlutterSecureStorage().read(key: ClavesAlmacen.tokenAcceso),
      'token-acceso',
    );
  });

  test('iniciarSesion rechaza roles distintos a ESTUDIANTE', () async {
    final servicio = AutenticacionServicio(
      apiServicio: ApiServicioSimulado(
        alPublicar: (_, __) async => _crearSesion(RolUsuario.DOCENTE).toJson(),
      ),
      almacenSeguro: const FlutterSecureStorage(),
    );

    expect(
      () => servicio.iniciarSesion(
        correo: 'docente@evalpro.com',
        contrasena: 'Segura123!',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'mensaje',
          Textos.errorSoloEstudiantes,
        ),
      ),
    );
    expect(
      await const FlutterSecureStorage().read(key: ClavesAlmacen.tokenAcceso),
      isNull,
    );
  });

  test('tieneSesionActiva invalida sesion con usuario no estudiante', () async {
    final almacenamientoSeguro = const FlutterSecureStorage();
    await almacenamientoSeguro.write(
      key: ClavesAlmacen.tokenAcceso,
      value: 'token-acceso',
    );
    await almacenamientoSeguro.write(
      key: ClavesAlmacen.usuarioActual,
      value: jsonEncode(
        _crearSesion(RolUsuario.ADMINISTRADOR).usuario.toJson(),
      ),
    );

    final servicio = AutenticacionServicio(
      apiServicio: ApiServicioSimulado(),
      almacenSeguro: almacenamientoSeguro,
    );

    final activa = await servicio.tieneSesionActiva();
    expect(activa, isFalse);
    expect(
      await almacenamientoSeguro.read(key: ClavesAlmacen.usuarioActual),
      isNull,
    );
  });
}

SesionAutenticada _crearSesion(RolUsuario rol) {
  return SesionAutenticada(
    tokenAcceso: 'token-acceso',
    tokenRefresh: 'token-refresh',
    usuario: Usuario(
      id: 'usuario-1',
      nombre: 'Ana',
      apellidos: 'Perez',
      correo: 'ana@evalpro.com',
      rol: rol,
      activo: true,
    ),
  );
}
