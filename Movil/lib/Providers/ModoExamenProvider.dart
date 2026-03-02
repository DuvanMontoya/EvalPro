/// @archivo   ModoExamenProvider.dart
/// @descripcion Expone el servicio de modo kiosco para su reutilizacion en providers.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../ModoExamen/ModoExamenServicio.dart';
import 'AutenticacionProvider.dart';

part 'ModoExamenProvider.g.dart';

@riverpod
ModoExamenServicio modoExamenServicio(ModoExamenServicioRef ref) {
  return ModoExamenServicio(
    telemetriaServicio: ref.watch(telemetriaServicioProvider),
    socketServicio: ref.watch(socketServicioProvider),
  );
}
