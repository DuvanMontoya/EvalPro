/// @archivo   SeguridadExamenProvider.dart
/// @descripcion Monitorea estado de seguridad/kiosco en tiempo real durante examen.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-05

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ModoExamen/ModoExamenServicio.dart';
import 'ExamenProvider.dart';
import 'ModoExamenProvider.dart';

enum NivelSeguridadExamen {
  estricto,
  parcial,
  critico,
}

class EstadoSeguridadExamen {
  static const Object _sinCambios = Object();

  final bool monitoreando;
  final bool cargando;
  final EstadoModoKiosco estadoKiosco;
  final ReporteIntegridadDispositivo? reporteIntegridad;
  final DateTime? actualizadoEn;
  final String? error;

  const EstadoSeguridadExamen({
    required this.monitoreando,
    required this.cargando,
    required this.estadoKiosco,
    required this.reporteIntegridad,
    required this.actualizadoEn,
    required this.error,
  });

  factory EstadoSeguridadExamen.inicial() {
    return EstadoSeguridadExamen(
      monitoreando: false,
      cargando: false,
      estadoKiosco: EstadoModoKiosco.desconocido(),
      reporteIntegridad: null,
      actualizadoEn: null,
      error: null,
    );
  }

  EstadoSeguridadExamen copyWith({
    bool? monitoreando,
    bool? cargando,
    EstadoModoKiosco? estadoKiosco,
    Object? reporteIntegridad = _sinCambios,
    Object? actualizadoEn = _sinCambios,
    Object? error = _sinCambios,
  }) {
    return EstadoSeguridadExamen(
      monitoreando: monitoreando ?? this.monitoreando,
      cargando: cargando ?? this.cargando,
      estadoKiosco: estadoKiosco ?? this.estadoKiosco,
      reporteIntegridad: identical(reporteIntegridad, _sinCambios)
          ? this.reporteIntegridad
          : reporteIntegridad as ReporteIntegridadDispositivo?,
      actualizadoEn: identical(actualizadoEn, _sinCambios)
          ? this.actualizadoEn
          : actualizadoEn as DateTime?,
      error: identical(error, _sinCambios) ? this.error : error as String?,
    );
  }

  bool get modoEstrictoActivo =>
      estadoKiosco.bloqueoEstrictoActivo && estadoKiosco.lockTaskActivo;

  int get puntajeIntegridad => reporteIntegridad?.puntajeIntegridad ?? 0;

  NivelSeguridadExamen get nivel {
    if (puntajeIntegridad >= 60) {
      return NivelSeguridadExamen.critico;
    }
    if (modoEstrictoActivo) {
      return NivelSeguridadExamen.estricto;
    }
    if (estadoKiosco.activo ||
        estadoKiosco.lockTaskActivo ||
        estadoKiosco.bloqueoEstrictoDisponible) {
      return NivelSeguridadExamen.parcial;
    }
    return NivelSeguridadExamen.critico;
  }

  String get etiquetaCorta {
    switch (nivel) {
      case NivelSeguridadExamen.estricto:
        return 'Modo estricto activo';
      case NivelSeguridadExamen.parcial:
        return 'Proteccion parcial';
      case NivelSeguridadExamen.critico:
        return 'Proteccion critica';
    }
  }

  Map<String, dynamic> generarDiagnosticoSoporte() {
    return <String, dynamic>{
      'monitoreando': monitoreando,
      'cargando': cargando,
      'nivel': nivel.name,
      'etiqueta': etiquetaCorta,
      'actualizadoEn': actualizadoEn?.toIso8601String(),
      'error': error,
      'estadoKiosco': <String, dynamic>{
        'activo': estadoKiosco.activo,
        'modo': estadoKiosco.modo,
        'lockTaskActivo': estadoKiosco.lockTaskActivo,
        'lockTaskPermitido': estadoKiosco.lockTaskPermitido,
        'dispositivoPropietario': estadoKiosco.dispositivoPropietario,
        'bloqueoEstrictoDisponible': estadoKiosco.bloqueoEstrictoDisponible,
        'bloqueoEstrictoActivo': estadoKiosco.bloqueoEstrictoActivo,
      },
      'reporteIntegridad': reporteIntegridad?.toJson(),
    };
  }
}

class SeguridadExamenNotifier extends StateNotifier<EstadoSeguridadExamen> {
  SeguridadExamenNotifier(this._ref) : super(EstadoSeguridadExamen.inicial());

  static const _intervaloMonitoreo = Duration(seconds: 4);

  final Ref _ref;
  Timer? _temporizador;
  bool _actualizando = false;

  void sincronizarConExamenActivo(bool hayExamenActivo) {
    if (!hayExamenActivo) {
      detenerMonitoreo();
      return;
    }
    iniciarMonitoreo();
  }

  void iniciarMonitoreo() {
    if (_temporizador != null) {
      return;
    }
    state = state.copyWith(monitoreando: true, cargando: true, error: null);
    unawaited(refrescar());
    _temporizador = Timer.periodic(_intervaloMonitoreo, (_) {
      unawaited(refrescar());
    });
  }

  Future<void> refrescar() async {
    if (_actualizando) {
      return;
    }
    final examenActivo = _ref.read(examenActivoProvider);
    if (examenActivo == null) {
      detenerMonitoreo();
      return;
    }

    _actualizando = true;
    try {
      final modoExamen = _ref.read(modoExamenServicioProvider);
      final estadoKiosco = await modoExamen.obtenerEstadoKiosco();
      final reporteIntegridad =
          await modoExamen.obtenerReporteIntegridadDispositivo();

      state = state.copyWith(
        monitoreando: true,
        cargando: false,
        estadoKiosco: estadoKiosco,
        reporteIntegridad: reporteIntegridad,
        actualizadoEn: DateTime.now(),
        error: null,
      );
    } catch (_) {
      state = state.copyWith(
        monitoreando: true,
        cargando: false,
        actualizadoEn: DateTime.now(),
        error: 'No fue posible refrescar el diagnostico de seguridad.',
      );
    } finally {
      _actualizando = false;
    }
  }

  void detenerMonitoreo() {
    _temporizador?.cancel();
    _temporizador = null;
    _actualizando = false;
    state = EstadoSeguridadExamen.inicial();
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }
}

final seguridadExamenProvider = StateNotifierProvider.autoDispose<
    SeguridadExamenNotifier, EstadoSeguridadExamen>((ref) {
  final notifier = SeguridadExamenNotifier(ref);
  ref.listen(
    examenActivoProvider,
    (anterior, actual) => notifier.sincronizarConExamenActivo(actual != null),
  );

  if (ref.read(examenActivoProvider) != null) {
    notifier.iniciarMonitoreo();
  }
  return notifier;
});
