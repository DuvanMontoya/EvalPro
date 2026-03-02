/// @archivo   SesionProvider.dart
/// @descripcion Maneja busqueda de sesiones por codigo y estado de carga asociado.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Modelos/SesionExamen.dart';
import 'AutenticacionProvider.dart';

part 'SesionProvider.g.dart';

class EstadoSesionBusqueda {
  final bool cargando;
  final SesionExamen? sesion;
  final String? error;

  const EstadoSesionBusqueda({
    required this.cargando,
    required this.sesion,
    required this.error,
  });

  const EstadoSesionBusqueda.inicial()
      : cargando = false,
        sesion = null,
        error = null;

  EstadoSesionBusqueda copyWith({
    bool? cargando,
    SesionExamen? sesion,
    String? error,
  }) {
    return EstadoSesionBusqueda(
      cargando: cargando ?? this.cargando,
      sesion: sesion ?? this.sesion,
      error: error,
    );
  }
}

@riverpod
class SesionActual extends _$SesionActual {
  @override
  EstadoSesionBusqueda build() => const EstadoSesionBusqueda.inicial();

  /// Busca una sesion por codigo de acceso.
  Future<void> buscarPorCodigo(String codigo) async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final sesion =
          await ref.read(sesionServicioProvider).buscarPorCodigo(codigo);
      state = state.copyWith(cargando: false, sesion: sesion, error: null);
    } catch (error) {
      state = state.copyWith(cargando: false, sesion: null, error: '$error');
    }
  }

  /// Limpia sesion seleccionada.
  void limpiar() {
    state = const EstadoSesionBusqueda.inicial();
  }
}
