/// @archivo   AutenticacionProvider.dart
/// @descripcion Gestiona estado de sesion y declara dependencias base de servicios y base local.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../BaseDatosLocal/BaseDatosLocal.dart';
import '../BaseDatosLocal/Daos/ExamenDao.dart';
import '../BaseDatosLocal/Daos/RespuestaDao.dart';
import '../BaseDatosLocal/Daos/TelemetriaDao.dart';
import '../Configuracion/Entorno.dart';
import '../Constantes/Textos.dart';
import '../Modelos/Usuario.dart';
import '../Servicios/ApiServicio.dart';
import '../Servicios/AutenticacionServicio.dart';
import '../Servicios/ExamenServicio.dart';
import '../Servicios/IntentoServicio.dart';
import '../Servicios/RespuestaServicio.dart';
import '../Servicios/SesionServicio.dart';
import '../Servicios/SincronizacionServicio.dart';
import '../Servicios/SocketServicio.dart';
import '../Servicios/TelemetriaServicio.dart';
import '../Utilidades/MapeadorErroresNegocio.dart';

part 'AutenticacionProvider.g.dart';

class EstadoAutenticacion {
  final bool inicializado;
  final bool estaAutenticado;
  final Usuario? usuario;
  final String? error;

  const EstadoAutenticacion({
    required this.inicializado,
    required this.estaAutenticado,
    required this.usuario,
    required this.error,
  });

  const EstadoAutenticacion.vacio()
      : inicializado = false,
        estaAutenticado = false,
        usuario = null,
        error = null;

  EstadoAutenticacion copyWith({
    bool? inicializado,
    bool? estaAutenticado,
    Usuario? usuario,
    String? error,
  }) {
    return EstadoAutenticacion(
      inicializado: inicializado ?? this.inicializado,
      estaAutenticado: estaAutenticado ?? this.estaAutenticado,
      usuario: usuario ?? this.usuario,
      error: error,
    );
  }
}

@riverpod
FlutterSecureStorage almacenamientoSeguro(AlmacenamientoSeguroRef ref) =>
    const FlutterSecureStorage();

@riverpod
BaseDatosLocal baseDatosLocal(BaseDatosLocalRef ref) => BaseDatosLocal();

@riverpod
ExamenDao examenDao(ExamenDaoRef ref) =>
    ExamenDao(ref.watch(baseDatosLocalProvider));

@riverpod
RespuestaDao respuestaDao(RespuestaDaoRef ref) =>
    RespuestaDao(ref.watch(baseDatosLocalProvider));

@riverpod
TelemetriaDao telemetriaDao(TelemetriaDaoRef ref) =>
    TelemetriaDao(ref.watch(baseDatosLocalProvider));

@riverpod
SocketServicio socketServicio(SocketServicioRef ref) => SocketServicio(
      almacenSeguro: ref.watch(almacenamientoSeguroProvider),
    );

@riverpod
ApiServicio apiServicio(ApiServicioRef ref) =>
    ApiServicio(almacenSeguro: ref.watch(almacenamientoSeguroProvider));

@riverpod
AutenticacionServicio autenticacionServicio(AutenticacionServicioRef ref) {
  return AutenticacionServicio(
    apiServicio: ref.watch(apiServicioProvider),
    almacenSeguro: ref.watch(almacenamientoSeguroProvider),
  );
}

@riverpod
SesionServicio sesionServicio(SesionServicioRef ref) =>
    SesionServicio(ref.watch(apiServicioProvider));

@riverpod
IntentoServicio intentoServicio(IntentoServicioRef ref) =>
    IntentoServicio(ref.watch(apiServicioProvider));

@riverpod
ExamenServicio examenServicio(ExamenServicioRef ref) =>
    ExamenServicio(ref.watch(apiServicioProvider));

@riverpod
RespuestaServicio respuestaServicio(RespuestaServicioRef ref) =>
    RespuestaServicio(ref.watch(apiServicioProvider));

@riverpod
TelemetriaServicio telemetriaServicio(TelemetriaServicioRef ref) {
  return TelemetriaServicio(
    apiServicio: ref.watch(apiServicioProvider),
    telemetriaDao: ref.watch(telemetriaDaoProvider),
  );
}

@riverpod
SincronizacionServicio sincronizacionServicio(SincronizacionServicioRef ref) {
  return SincronizacionServicio(
    respuestaDao: ref.watch(respuestaDaoProvider),
    telemetriaDao: ref.watch(telemetriaDaoProvider),
    respuestaServicio: ref.watch(respuestaServicioProvider),
    telemetriaServicio: ref.watch(telemetriaServicioProvider),
    socketServicio: ref.watch(socketServicioProvider),
    diasRetencionTelemetria: Entorno.diasRetencionTelemetria,
  );
}

@riverpod
class AutenticacionEstado extends _$AutenticacionEstado {
  @override
  EstadoAutenticacion build() {
    _cargarSesion();
    return const EstadoAutenticacion.vacio();
  }

  /// Lee credenciales guardadas y actualiza estado de sesion.
  Future<void> _cargarSesion() async {
    final servicio = ref.read(autenticacionServicioProvider);
    final activa = await servicio.tieneSesionActiva();
    final usuario = await servicio.obtenerUsuarioActual();

    state = state.copyWith(
      inicializado: true,
      estaAutenticado: activa,
      usuario: usuario,
      error: null,
    );
  }

  /// Ejecuta login y persiste estado autenticado.
  Future<void> iniciarSesion(
      {required String correo, required String contrasena}) async {
    try {
      final sesion = await ref
          .read(autenticacionServicioProvider)
          .iniciarSesion(correo: correo, contrasena: contrasena);
      state = state.copyWith(
        inicializado: true,
        estaAutenticado: true,
        usuario: sesion.usuario,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
          inicializado: true,
          estaAutenticado: false,
          usuario: null,
          error: MapeadorErroresNegocio.mapear(
            error,
            mensajePorDefecto: Textos.errorInicioSesion,
          ));
    }
  }

  /// Cierra sesion remota/local y limpia estado.
  Future<void> cerrarSesion() async {
    await ref.read(autenticacionServicioProvider).cerrarSesion();
    state = const EstadoAutenticacion(
      inicializado: true,
      estaAutenticado: false,
      usuario: null,
      error: null,
    );
  }
}
