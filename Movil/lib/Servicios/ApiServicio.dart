/// @archivo   ApiServicio.dart
/// @descripcion Configura Dio con interceptores JWT, refresh automatico y parseo de respuesta estandar.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Configuracion/Entorno.dart';
import '../Constantes/ApiEndpoints.dart';
import '../Constantes/ClavesAlmacen.dart';
import 'ApiAuxiliar.dart';

class ApiServicio {
  final Dio _cliente;
  final Dio _clienteRefresco;
  final FlutterSecureStorage _almacenSeguro;
  final void Function()? _alExpirarSesion;

  ApiServicio({
    required FlutterSecureStorage almacenSeguro,
    void Function()? alExpirarSesion,
  })  : _almacenSeguro = almacenSeguro,
        _alExpirarSesion = alExpirarSesion,
        _cliente = Dio(
          BaseOptions(
            baseUrl: Entorno.apiUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ),
        _clienteRefresco = Dio(
          BaseOptions(
            baseUrl: Entorno.apiUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _cliente.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// Agrega token de acceso en cada peticion autenticada.
  Future<void> _onRequest(
    RequestOptions opciones,
    RequestInterceptorHandler manejador,
  ) async {
    final token = await _almacenSeguro.read(key: ClavesAlmacen.tokenAcceso);
    final autorizacionExistente = opciones.headers['Authorization'];
    final yaTieneAutorizacion = autorizacionExistente is String
        ? autorizacionExistente.trim().isNotEmpty
        : autorizacionExistente != null;
    if (token != null && token.isNotEmpty && !yaTieneAutorizacion) {
      opciones.headers['Authorization'] = 'Bearer $token';
    }
    manejador.next(opciones);
  }

  /// Maneja errores 401 intentando refresco de token y reintento de la solicitud.
  Future<void> _onError(
      DioException error, ErrorInterceptorHandler manejador) async {
    final esNoAutorizado = error.response?.statusCode == 401;
    final ruta = error.requestOptions.path;
    final fueReintentada = error.requestOptions.extra['reintentada'] == true;
    final esRefresco = ruta.contains(ApiEndpoints.autenticacionRefrescar);

    if (!esNoAutorizado || fueReintentada || esRefresco) {
      manejador.next(error);
      return;
    }

    final nuevoToken = await refrescarTokenAcceso(
      clienteRefresco: _clienteRefresco,
      almacenSeguro: _almacenSeguro,
    );
    if (nuevoToken == null) {
      await cerrarSesionLocal(
        almacenSeguro: _almacenSeguro,
        alExpirarSesion: _alExpirarSesion,
      );
      manejador.next(error);
      return;
    }

    final opcionesOriginales = error.requestOptions;
    try {
      final respuesta = await _cliente.request<dynamic>(
        opcionesOriginales.path,
        data: opcionesOriginales.data,
        queryParameters: opcionesOriginales.queryParameters,
        options: Options(
          method: opcionesOriginales.method,
          headers: <String, dynamic>{
            ...opcionesOriginales.headers,
            'Authorization': 'Bearer $nuevoToken',
          },
          contentType: opcionesOriginales.contentType,
          responseType: opcionesOriginales.responseType,
          extra: <String, dynamic>{
            ...opcionesOriginales.extra,
            'reintentada': true,
          },
        ),
      );
      manejador.resolve(respuesta);
    } catch (errorReintento) {
      await cerrarSesionLocal(
        almacenSeguro: _almacenSeguro,
        alExpirarSesion: _alExpirarSesion,
      );
      manejador.next(error);
    }
  }

  /// Ejecuta GET y transforma el campo datos del contrato estandar.
  Future<T> obtener<T>(
    String ruta,
    T Function(Object? valor) mapear, {
    Map<String, dynamic>? consulta,
  }) async {
    final respuesta =
        await _cliente.get<dynamic>(ruta, queryParameters: consulta);
    return mapearDatosApi<T>(respuesta, mapear);
  }

  /// Ejecuta POST y transforma el campo datos del contrato estandar.
  Future<T> publicar<T>(
    String ruta,
    T Function(Object? valor) mapear, {
    Object? cuerpo,
    Map<String, dynamic>? encabezados,
  }) async {
    final respuesta = await _cliente.post<dynamic>(
      ruta,
      data: cuerpo,
      options: Options(headers: encabezados),
    );
    return mapearDatosApi<T>(respuesta, mapear);
  }

  /// Ejecuta PATCH y transforma el campo datos del contrato estandar.
  Future<T> actualizar<T>(
    String ruta,
    T Function(Object? valor) mapear, {
    Object? cuerpo,
  }) async {
    final respuesta = await _cliente.patch<dynamic>(ruta, data: cuerpo);
    return mapearDatosApi<T>(respuesta, mapear);
  }

  /// Ejecuta DELETE y transforma el campo datos del contrato estandar.
  Future<T> eliminar<T>(String ruta, T Function(Object? valor) mapear) async {
    final respuesta = await _cliente.delete<dynamic>(ruta);
    return mapearDatosApi<T>(respuesta, mapear);
  }
}
