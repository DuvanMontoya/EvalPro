/// @archivo   ConectividadProvider.dart
/// @descripcion Observa conectividad de red y dispara sincronizacion al recuperar internet.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Utilidades/ValidadorConectividad.dart';
import 'AutenticacionProvider.dart';
import 'ModoExamenProvider.dart';

part 'ConectividadProvider.g.dart';

@riverpod
class ConectividadEstado extends _$ConectividadEstado {
  StreamSubscription<List<ConnectivityResult>>? _suscripcion;
  List<ConnectivityResult> _ultimoEstadoRed = const <ConnectivityResult>[
    ConnectivityResult.none,
  ];
  DateTime? _inicioSinRed;
  final List<DateTime> _reconexionesRecientes = <DateTime>[];

  @override
  bool build() {
    _inicializar();
    ref.onDispose(() {
      _suscripcion?.cancel();
    });
    return true;
  }

  Future<void> _inicializar() async {
    final connectivity = Connectivity();
    final actual = await connectivity.checkConnectivity();
    final resultadosActuales = _normalizarResultados(actual);
    _ultimoEstadoRed = resultadosActuales;
    state = ValidadorConectividad.estaConectado(resultadosActuales);
    _inicioSinRed = state ? null : DateTime.now().toUtc();

    _suscripcion =
        connectivity.onConnectivityChanged.listen((resultados) async {
      final resultadosNormalizados = _normalizarResultados(resultados);
      final tipoRedAnterior = _obtenerTipoRedPrincipal(_ultimoEstadoRed);
      final tipoRedNuevo = _obtenerTipoRedPrincipal(resultadosNormalizados);
      final estabaConectado = state;
      final ahoraConectado =
          ValidadorConectividad.estaConectado(resultadosNormalizados);
      state = ahoraConectado;
      final ahoraUtc = DateTime.now().toUtc();

      if (estabaConectado && !ahoraConectado) {
        _inicioSinRed = ahoraUtc;
        unawaited(
          _registrarEventoCambioRed(
            evento: 'DESCONECTADO',
            tipoRedAnterior: tipoRedAnterior,
            tipoRedNuevo: 'SIN_RED',
            reconectado: false,
          ),
        );
      }

      if (!estabaConectado && ahoraConectado) {
        final inicioSinRed = _inicioSinRed;
        final duracionSinRedMs = inicioSinRed == null
            ? null
            : ahoraUtc.difference(inicioSinRed).inMilliseconds;
        _inicioSinRed = null;

        _reconexionesRecientes.add(ahoraUtc);
        _depurarReconexionesRecientes(ahoraUtc);
        final reconexionesVentana = _reconexionesRecientes.length;

        unawaited(
          _registrarEventoCambioRed(
            evento: 'RECONECTADO',
            tipoRedAnterior: tipoRedAnterior,
            tipoRedNuevo: tipoRedNuevo,
            reconectado: true,
            duracionSinRedMs: duracionSinRedMs,
            reconexionesEnVentana: reconexionesVentana,
          ),
        );
      }

      if (estabaConectado &&
          ahoraConectado &&
          tipoRedAnterior != tipoRedNuevo &&
          tipoRedAnterior != 'SIN_RED' &&
          tipoRedNuevo != 'SIN_RED') {
        unawaited(
          _registrarEventoCambioRed(
            evento: 'CAMBIO_TIPO_RED',
            tipoRedAnterior: tipoRedAnterior,
            tipoRedNuevo: tipoRedNuevo,
            reconectado: false,
          ),
        );
      }

      _ultimoEstadoRed = resultadosNormalizados;

      if (!estabaConectado && ahoraConectado) {
        await ref
            .read(sincronizacionServicioProvider)
            .sincronizarPendientesAlRecuperarConexion();
      }
    });
  }

  List<ConnectivityResult> _normalizarResultados(
    List<ConnectivityResult> resultados,
  ) {
    final sinDuplicados = <ConnectivityResult>{...resultados}.toList();
    if (sinDuplicados.isEmpty) {
      return const <ConnectivityResult>[ConnectivityResult.none];
    }
    return sinDuplicados;
  }

  String _obtenerTipoRedPrincipal(List<ConnectivityResult> resultados) {
    if (resultados.contains(ConnectivityResult.wifi)) {
      return 'WIFI';
    }
    if (resultados.contains(ConnectivityResult.mobile)) {
      return 'MOVIL';
    }
    if (resultados.contains(ConnectivityResult.ethernet)) {
      return 'ETHERNET';
    }
    if (resultados.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    }
    if (resultados.contains(ConnectivityResult.bluetooth)) {
      return 'BLUETOOTH';
    }
    if (resultados.contains(ConnectivityResult.other)) {
      return 'OTRO';
    }
    return 'SIN_RED';
  }

  void _depurarReconexionesRecientes(DateTime referenciaUtc) {
    final limite = referenciaUtc.subtract(const Duration(seconds: 120));
    _reconexionesRecientes.removeWhere((fecha) => fecha.isBefore(limite));
  }

  Future<void> _registrarEventoCambioRed({
    required String evento,
    required String tipoRedAnterior,
    required String tipoRedNuevo,
    required bool reconectado,
    int? duracionSinRedMs,
    int? reconexionesEnVentana,
  }) async {
    final idIntento = ref.read(modoExamenServicioProvider).idIntentoMonitoreado;
    if (idIntento == null || idIntento.trim().isEmpty) {
      return;
    }

    await ref.read(telemetriaServicioProvider).registrarEventoSync(
      idIntento: idIntento,
      tipo: TipoEventoTelemetria.INCIDENTE_REGISTRADO,
      descripcion: 'EVENTO_RED_$evento',
      metadatos: <String, dynamic>{
        'evento': evento,
        'tipoRedAnterior': tipoRedAnterior,
        'tipoRedNuevo': tipoRedNuevo,
        'reconectado': reconectado,
        if (duracionSinRedMs != null) 'duracionSinRedMs': duracionSinRedMs,
        if (reconexionesEnVentana != null)
          'reconexionesEnVentana': reconexionesEnVentana,
        'ventanaAnalisisSegundos': 120,
        'timestampClienteUtc': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }
}
