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

import '../Constantes/Textos.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Servicios/SocketServicio.dart';
import '../Servicios/TelemetriaServicio.dart';

class EstadoModoKiosco {
  final bool activo;
  final bool lockTaskActivo;
  final bool lockTaskPermitido;
  final bool dispositivoPropietario;
  final bool bloqueoEstrictoDisponible;
  final bool bloqueoEstrictoActivo;
  final String modo;

  const EstadoModoKiosco({
    required this.activo,
    required this.lockTaskActivo,
    required this.lockTaskPermitido,
    required this.dispositivoPropietario,
    required this.bloqueoEstrictoDisponible,
    required this.bloqueoEstrictoActivo,
    required this.modo,
  });

  factory EstadoModoKiosco.desconocido() => const EstadoModoKiosco(
        activo: false,
        lockTaskActivo: false,
        lockTaskPermitido: false,
        dispositivoPropietario: false,
        bloqueoEstrictoDisponible: false,
        bloqueoEstrictoActivo: false,
        modo: 'INACTIVO',
      );

  factory EstadoModoKiosco.desdeMapa(Object? origen) {
    if (origen is! Map) {
      return EstadoModoKiosco.desconocido();
    }

    bool leerBool(String clave) {
      final valor = origen[clave];
      return valor is bool ? valor : false;
    }

    String leerTexto(String clave) {
      final valor = origen[clave];
      return valor is String && valor.trim().isNotEmpty
          ? valor.trim()
          : 'INACTIVO';
    }

    return EstadoModoKiosco(
      activo: leerBool('activo'),
      lockTaskActivo: leerBool('lockTaskActivo'),
      lockTaskPermitido: leerBool('lockTaskPermitido'),
      dispositivoPropietario: leerBool('dispositivoPropietario'),
      bloqueoEstrictoDisponible: leerBool('bloqueoEstrictoDisponible'),
      bloqueoEstrictoActivo: leerBool('bloqueoEstrictoActivo'),
      modo: leerTexto('modo'),
    );
  }
}

class ModoExamenServicio with WidgetsBindingObserver {
  static const _canal = MethodChannel('com.evalPro.movil/modoKiosco');
  static const bool _requerirBloqueoEstricto = bool.fromEnvironment(
    'KIOSCO_ESTRICTO_REQUERIDO',
    defaultValue: true,
  );

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

  /// Verifica antes de iniciar el intento que existe capacidad de bloqueo estricto.
  Future<void> validarDisponibilidadBloqueoEstricto() async {
    if (!Platform.isAndroid) {
      return;
    }
    if (!_requerirBloqueoEstricto) {
      return;
    }

    try {
      final estado = await obtenerEstadoKiosco();
      if (!estado.bloqueoEstrictoDisponible) {
        throw StateError(Textos.errorBloqueoEstrictoNoDisponible);
      }
    } on PlatformException catch (_) {
      throw StateError(Textos.errorBloqueoEstrictoNoDisponible);
    }
  }

  /// Consulta capacidades nativas de kiosco en el dispositivo actual.
  Future<EstadoModoKiosco> obtenerEstadoKiosco() async {
    final respuesta = await _canal.invokeMethod<Object?>('estado');
    return EstadoModoKiosco.desdeMapa(respuesta);
  }

  /// Activa el modo kiosco. Retorna true si se activo exitosamente.
  /// Lanza PlatformException si el SO rechaza el bloqueo.
  Future<bool> activarModoKiosco() async {
    await _activarProteccionVisual();
    if (!Platform.isAndroid) {
      return _proteccionVisualActiva;
    }
    try {
      final respuesta = await _canal.invokeMethod<Object?>(
        'activar',
        <String, dynamic>{'requerirBloqueoEstricto': _requerirBloqueoEstricto},
      );
      final estado = EstadoModoKiosco.desdeMapa(respuesta);

      if (_requerirBloqueoEstricto && !estado.bloqueoEstrictoActivo) {
        throw StateError(Textos.errorBloqueoEstrictoNoDisponible);
      }

      if (!estado.activo) {
        throw StateError(Textos.errorActivacionModoExamen);
      }

      return true;
    } on PlatformException catch (error) {
      if (error.code == 'BLOQUEO_ESTRICTO_NO_DISPONIBLE') {
        throw StateError(Textos.errorBloqueoEstrictoNoDisponible);
      }
      await _telemetriaServicio.registrarError(
        'MODO_KIOSCO_FALLO',
        error.message,
        idIntento: _idIntentoActivo,
      );
      throw StateError(Textos.errorActivacionModoExamen);
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
      unawaited(_reforzarInmersionNativa());
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

  Future<void> _reforzarInmersionNativa() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      await _canal.invokeMethod<void>('reforzarInmersion');
    } catch (_) {
      // Ignorar en plataformas sin canal o versiones antiguas.
    }
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
