/// @archivo   TelemetriaDaoPrueba_test.dart
/// @descripcion Prueba limpieza historica de eventos de telemetria sincronizados.
/// @modulo    test/BaseDatosLocal
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movil/BaseDatosLocal/BaseDatosLocal.dart';
import 'package:movil/BaseDatosLocal/Daos/TelemetriaDao.dart';

void main() {
  late BaseDatosLocal baseDatosLocal;
  late TelemetriaDao telemetriaDao;

  setUp(() {
    baseDatosLocal = BaseDatosLocal.pruebas(NativeDatabase.memory());
    telemetriaDao = TelemetriaDao(baseDatosLocal);
  });

  tearDown(() async {
    await baseDatosLocal.close();
  });

  test('eliminarSincronizadosAnterioresA no elimina pendientes sin sincronizar',
      () async {
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final fechaAntigua = ahora - const Duration(days: 12).inMilliseconds;
    final fechaReciente = ahora - const Duration(days: 2).inMilliseconds;

    await telemetriaDao.guardarEvento(
      id: 'evento-antiguo',
      idIntento: 'intento-1',
      tipo: 'RESPUESTA_GUARDADA',
      metadatos: null,
      numeroPregunta: 1,
      tiempoTranscurrido: 10,
      fechaEvento: fechaAntigua,
      esSincronizada: true,
    );
    await telemetriaDao.guardarEvento(
      id: 'evento-reciente',
      idIntento: 'intento-1',
      tipo: 'CAMBIO_PREGUNTA',
      metadatos: null,
      numeroPregunta: 2,
      tiempoTranscurrido: 15,
      fechaEvento: fechaReciente,
      esSincronizada: true,
    );
    await telemetriaDao.guardarEvento(
      id: 'evento-pendiente',
      idIntento: 'intento-1',
      tipo: 'RESPUESTA_GUARDADA',
      metadatos: null,
      numeroPregunta: 3,
      tiempoTranscurrido: 20,
      fechaEvento: fechaAntigua,
      esSincronizada: false,
    );

    final eliminados =
        await telemetriaDao.eliminarSincronizadosAnterioresA(fechaReciente);
    expect(eliminados, 1);

    final restantes =
        await baseDatosLocal.select(baseDatosLocal.telemetriaLocalTabla).get();
    expect(restantes.map((fila) => fila.id).toSet(), <String>{
      'evento-reciente',
      'evento-pendiente',
    });
  });
}
