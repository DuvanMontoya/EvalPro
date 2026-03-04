/// @archivo   ApiServicioSimulado.dart
/// @descripcion Provee un ApiServicio controlado para pruebas sin llamadas de red.
/// @modulo    test/Auxiliares
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:movil/Servicios/ApiServicio.dart';

typedef ManejadorPublicarSimulado = Future<Object?> Function(
  String ruta,
  Object? cuerpo,
);

typedef ManejadorObtenerSimulado = Future<Object?> Function(
  String ruta,
  Map<String, dynamic>? consulta,
);

class ApiServicioSimulado extends ApiServicio {
  final ManejadorPublicarSimulado? _alPublicar;
  final ManejadorObtenerSimulado? _alObtener;

  ApiServicioSimulado({
    ManejadorPublicarSimulado? alPublicar,
    ManejadorObtenerSimulado? alObtener,
  })  : _alPublicar = alPublicar,
        _alObtener = alObtener,
        super(almacenSeguro: const FlutterSecureStorage());

  @override
  Future<T> publicar<T>(
    String ruta,
    T Function(Object? valor) mapear, {
    Object? cuerpo,
    Map<String, dynamic>? encabezados,
  }) async {
    if (_alPublicar == null) {
      throw UnsupportedError('No se definio manejador simulado para POST');
    }
    final valor = await _alPublicar(ruta, cuerpo);
    return mapear(valor);
  }

  @override
  Future<T> obtener<T>(
    String ruta,
    T Function(Object? valor) mapear, {
    Map<String, dynamic>? consulta,
  }) async {
    if (_alObtener == null) {
      throw UnsupportedError('No se definio manejador simulado para GET');
    }
    final valor = await _alObtener(ruta, consulta);
    return mapear(valor);
  }
}
