/// @archivo   SeguridadExamenProvider_test.dart
/// @descripcion Valida clasificacion del estado de seguridad y diagnostico para soporte.
/// @modulo    test/Providers
/// @autor     EvalPro
/// @fecha     2026-03-05

import 'package:flutter_test/flutter_test.dart';
import 'package:movil/ModoExamen/ModoExamenServicio.dart';
import 'package:movil/Providers/SeguridadExamenProvider.dart';

void main() {
  test('nivel estricto cuando bloqueo estricto y lock task estan activos', () {
    final estado = EstadoSeguridadExamen(
      monitoreando: true,
      cargando: false,
      estadoKiosco: const EstadoModoKiosco(
        activo: true,
        lockTaskActivo: true,
        lockTaskPermitido: true,
        dispositivoPropietario: true,
        bloqueoEstrictoDisponible: true,
        bloqueoEstrictoActivo: true,
        modo: 'DEVICE_OWNER',
      ),
      reporteIntegridad: _reporte(puntajeIntegridad: 10),
      actualizadoEn: DateTime.now(),
      error: null,
    );

    expect(estado.nivel, NivelSeguridadExamen.estricto);
    expect(estado.etiquetaCorta, 'Modo estricto activo');
  });

  test('nivel parcial cuando kiosco esta activo sin bloqueo estricto', () {
    final estado = EstadoSeguridadExamen(
      monitoreando: true,
      cargando: false,
      estadoKiosco: const EstadoModoKiosco(
        activo: true,
        lockTaskActivo: true,
        lockTaskPermitido: true,
        dispositivoPropietario: false,
        bloqueoEstrictoDisponible: false,
        bloqueoEstrictoActivo: false,
        modo: 'SCREEN_PINNING',
      ),
      reporteIntegridad: _reporte(puntajeIntegridad: 35),
      actualizadoEn: DateTime.now(),
      error: null,
    );

    expect(estado.nivel, NivelSeguridadExamen.parcial);
    expect(estado.etiquetaCorta, 'Proteccion parcial');
  });

  test('nivel critico cuando puntaje de integridad supera el umbral', () {
    final estado = EstadoSeguridadExamen(
      monitoreando: true,
      cargando: false,
      estadoKiosco: EstadoModoKiosco.desconocido(),
      reporteIntegridad: _reporte(
        puntajeIntegridad: 80,
        razones: const <String>['ROOT_O_JAILBREAK_DETECTADO'],
      ),
      actualizadoEn: DateTime.now(),
      error: null,
    );

    expect(estado.nivel, NivelSeguridadExamen.critico);
    expect(estado.etiquetaCorta, 'Proteccion critica');
  });

  test('diagnostico de soporte incluye secciones de kiosco e integridad', () {
    final estado = EstadoSeguridadExamen(
      monitoreando: true,
      cargando: false,
      estadoKiosco: const EstadoModoKiosco(
        activo: true,
        lockTaskActivo: true,
        lockTaskPermitido: true,
        dispositivoPropietario: true,
        bloqueoEstrictoDisponible: true,
        bloqueoEstrictoActivo: true,
        modo: 'DEVICE_OWNER',
      ),
      reporteIntegridad: _reporte(puntajeIntegridad: 5),
      actualizadoEn: DateTime.now(),
      error: null,
    );

    final diagnostico = estado.generarDiagnosticoSoporte();
    expect(diagnostico['estadoKiosco'], isA<Map<String, dynamic>>());
    expect(diagnostico['reporteIntegridad'], isA<Map<String, dynamic>>());
    expect(diagnostico['nivel'], 'estricto');
  });
}

ReporteIntegridadDispositivo _reporte({
  required int puntajeIntegridad,
  List<String> razones = const <String>[],
}) {
  return ReporteIntegridadDispositivo(
    plataforma: 'ANDROID',
    rootDetectado: false,
    appDepurable: false,
    opcionesDesarrolladorActivas: false,
    adbActivo: false,
    emuladorDetectado: false,
    lockTaskPermitido: true,
    lockTaskActivo: true,
    dispositivoPropietario: true,
    bloqueoEstrictoDisponible: true,
    bloqueoEstrictoActivo: true,
    puntajeIntegridad: puntajeIntegridad,
    razonesRiesgo: razones,
    timestamp: DateTime.now().toUtc().toIso8601String(),
  );
}
