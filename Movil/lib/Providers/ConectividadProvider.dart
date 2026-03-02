/// @archivo   ConectividadProvider.dart
/// @descripcion Observa conectividad de red y dispara sincronizacion al recuperar internet.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Utilidades/ValidadorConectividad.dart';
import 'AutenticacionProvider.dart';

part 'ConectividadProvider.g.dart';

@riverpod
class ConectividadEstado extends _$ConectividadEstado {
  StreamSubscription<List<ConnectivityResult>>? _suscripcion;

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
    state = ValidadorConectividad.estaConectado(actual);

    _suscripcion =
        connectivity.onConnectivityChanged.listen((resultados) async {
      final estabaConectado = state;
      final ahoraConectado = ValidadorConectividad.estaConectado(resultados);
      state = ahoraConectado;

      if (!estabaConectado && ahoraConectado) {
        await ref
            .read(sincronizacionServicioProvider)
            .sincronizarPendientesAlRecuperarConexion();
      }
    });
  }
}
