/// @archivo   ModoExamenServicio.dart
/// @descripcion Controla modo kiosco y reporta eventos de fraude por cambios de ciclo de vida.
/// @modulo    ModoExamen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Servicios/SocketServicio.dart';
import '../Servicios/TelemetriaServicio.dart';

class ModoExamenServicio with WidgetsBindingObserver {
  static const _canal = MethodChannel('com.evalPro.movil/modoKiosco');

  final TelemetriaServicio _telemetriaServicio;
  final SocketServicio _socketServicio;

  String? _idIntentoActivo;
  Timer? _restauradorUiTimer;
  bool _proteccionVisualActiva = false;

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
    await _activarProteccionVisual();
    try {
      final resultado = await _canal.invokeMethod<bool>('activar');
      return resultado ?? true;
    } on PlatformException catch (error) {
      await _telemetriaServicio.registrarError(
        'MODO_KIOSCO_FALLO',
        error.message,
        idIntento: _idIntentoActivo,
      );
      return _proteccionVisualActiva;
    }
  }

  /// Desactiva el modo kiosco. Llamar siempre al enviar o anular el examen.
  Future<void> desactivarModoKiosco() async {
    try {
      await _canal.invokeMethod<void>('desactivar');
    } catch (_) {
      // Ignorar fallo nativo y restaurar siempre desde Flutter.
    } finally {
      await _desactivarProteccionVisual();
    }
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
      return;
    }

    if (estado == AppLifecycleState.resumed) {
      unawaited(_activarProteccionVisual());
    }
  }

  Future<void> _activarProteccionVisual() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(
      const <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
    await SystemChrome.setSystemUIChangeCallback((overlaysVisibles) async {
      if (!overlaysVisibles || !_proteccionVisualActiva) {
        return;
      }
      _restauradorUiTimer?.cancel();
      _restauradorUiTimer = Timer(const Duration(milliseconds: 900), () {
        if (_proteccionVisualActiva) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        }
      });
    });
    await WakelockPlus.enable();
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (_) {
        // Continuar con protección parcial si el plugin no está disponible.
      }
    }
    _proteccionVisualActiva = true;
  }

  Future<void> _desactivarProteccionVisual() async {
    _restauradorUiTimer?.cancel();
    _restauradorUiTimer = null;
    _proteccionVisualActiva = false;
    await SystemChrome.setSystemUIChangeCallback(null);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[]);
    await WakelockPlus.disable();
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (_) {
        // Ignorar si no estaba activo.
      }
    }
  }
}
