/// @archivo   ModoExamenServicio.dart
/// @descripcion Controla modo kiosco y reporta eventos de fraude por cambios de ciclo de vida.
/// @modulo    ModoExamen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Servicios/SocketServicio.dart';
import '../Servicios/TelemetriaServicio.dart';

class ModoExamenServicio with WidgetsBindingObserver {
  static const _canal = MethodChannel('com.evalPro.movil/modoKiosco');

  final TelemetriaServicio _telemetriaServicio;
  final SocketServicio _socketServicio;

  String? _idIntentoActivo;

  ModoExamenServicio({
    required TelemetriaServicio telemetriaServicio,
    required SocketServicio socketServicio,
  })  : _telemetriaServicio = telemetriaServicio,
        _socketServicio = socketServicio;

  /// Registra el intento activo y habilita monitoreo de ciclo de vida.
  void iniciarMonitoreo(String idIntento) {
    _idIntentoActivo = idIntento;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Detiene observacion de ciclo de vida y limpia intento activo.
  void detenerMonitoreo() {
    WidgetsBinding.instance.removeObserver(this);
    _idIntentoActivo = null;
  }

  /// Activa el modo kiosco. Retorna true si se activo exitosamente.
  /// Lanza PlatformException si el SO rechaza el bloqueo.
  Future<bool> activarModoKiosco() async {
    try {
      final resultado = await _canal.invokeMethod<bool>('activar');
      return resultado ?? false;
    } on PlatformException catch (error) {
      await _telemetriaServicio.registrarError(
        'MODO_KIOSCO_FALLO',
        error.message,
        idIntento: _idIntentoActivo,
      );
      return false;
    }
  }

  /// Desactiva el modo kiosco. Llamar siempre al enviar o anular el examen.
  Future<void> desactivarModoKiosco() async {
    await _canal.invokeMethod<void>('desactivar');
  }

  /// Detecta envios al fondo y registra fraude segun reglas del proyecto.
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    final idIntento = _idIntentoActivo;
    if (idIntento == null) {
      return;
    }

    if (estado == AppLifecycleState.paused ||
        estado == AppLifecycleState.inactive) {
      try {
        unawaited(
          _telemetriaServicio.registrarEventoSync(
            idIntento: idIntento,
            tipo: TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO,
          ),
        );
        _socketServicio.emitirAlertaFraude(
          TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO,
          idIntento: idIntento,
        );
      } catch (_) {
        // Nunca romper la UI por fallas de telemetria/fraude en segundo plano.
      }
    }
  }
}
