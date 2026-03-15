/// @archivo   SincronizacionServicio.dart
/// @descripcion Aplica politica de reintentos y sincronizacion batch de datos offline.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';
import 'dart:convert';

import '../BaseDatosLocal/Daos/RespuestaDao.dart';
import '../BaseDatosLocal/Daos/TelemetriaDao.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';
import '../Modelos/RespuestaLocal.dart';
import 'RespuestaServicio.dart';
import 'SocketServicio.dart';
import 'TelemetriaServicio.dart';

class SincronizacionServicio {
  final int _diasRetencionTelemetria;
  final RespuestaDao _respuestaDao;
  final TelemetriaDao _telemetriaDao;
  final RespuestaServicio _respuestaServicio;
  final TelemetriaServicio _telemetriaServicio;
  final SocketServicio _socketServicio;

  SincronizacionServicio({
    required RespuestaDao respuestaDao,
    required TelemetriaDao telemetriaDao,
    required RespuestaServicio respuestaServicio,
    required TelemetriaServicio telemetriaServicio,
    required SocketServicio socketServicio,
    required int diasRetencionTelemetria,
  })  : _respuestaDao = respuestaDao,
        _diasRetencionTelemetria = diasRetencionTelemetria,
        _telemetriaDao = telemetriaDao,
        _respuestaServicio = respuestaServicio,
        _telemetriaServicio = telemetriaServicio,
        _socketServicio = socketServicio;

  /// Sincroniza respuestas y telemetria pendientes tras recuperar conectividad.
  Future<void> sincronizarPendientesAlRecuperarConexion() async {
    await _sincronizarRespuestasPendientes();
    await _sincronizarTelemetriaPendiente();
    await _depurarTelemetriaHistorica();
  }

  Future<void> _sincronizarRespuestasPendientes() async {
    final pendientes = await _respuestaDao.listarPendientes();
    if (pendientes.isEmpty) {
      return;
    }

    final porIntento = <String, List<RespuestaLocal>>{};
    for (final respuesta in pendientes) {
      final opciones =
          (jsonDecode(respuesta.opcionesSeleccionadas ?? '[]') as List<dynamic>)
              .map((valor) => valor as String)
              .toList();

      final modelo = RespuestaLocal(
        id: respuesta.id,
        idIntento: respuesta.idIntento,
        idPregunta: respuesta.idPregunta,
        valorTexto: respuesta.valorTexto,
        opcionesSeleccionadas: opciones,
        tiempoRespuesta: respuesta.tiempoRespuesta,
        fechaRespuesta:
            DateTime.fromMillisecondsSinceEpoch(respuesta.fechaRespuesta),
        esSincronizada: respuesta.esSincronizada,
        reintentosSincronizacion: respuesta.reintentosSincronizacion,
      );

      porIntento
          .putIfAbsent(modelo.idIntento, () => <RespuestaLocal>[])
          .add(modelo);
    }

    for (final entrada in porIntento.entries) {
      final idIntento = entrada.key;
      final respuestas = entrada.value;
      final reintentos = respuestas
          .map((respuesta) => respuesta.reintentosSincronizacion)
          .fold<int>(0, (maximo, actual) => actual > maximo ? actual : maximo);

      if (reintentos >= 10) {
        await _manejarExcesoReintentos(idIntento);
        continue;
      }

      await Future<void>.delayed(_obtenerEsperaPorReintento(reintentos));

      try {
        await _respuestaServicio.sincronizarLote(idIntento, respuestas);
        await _respuestaDao
            .marcarSincronizadas(respuestas.map((dato) => dato.id).toList());
      } catch (_) {
        for (final respuesta in respuestas) {
          await _respuestaDao.incrementarReintentos(respuesta.id);
        }
      }
    }
  }

  Future<void> _sincronizarTelemetriaPendiente() async {
    final pendientes = await _telemetriaDao.listarPendientes();
    if (pendientes.isEmpty) {
      return;
    }

    for (final evento in pendientes) {
      try {
        await _telemetriaServicio.sincronizarEventoPendiente(
          idIntento: evento.idIntento,
          tipo: TipoEventoTelemetriaTransformador.desdeNombre(evento.tipo),
          metadatos: evento.metadatos == null || evento.metadatos!.isEmpty
              ? null
              : jsonDecode(evento.metadatos!) as Map<String, dynamic>,
          numeroPregunta: evento.numeroPregunta,
          tiempoTranscurrido: evento.tiempoTranscurrido,
        );
        await _telemetriaDao.marcarSincronizados(<String>[evento.id]);
      } catch (_) {
        // Se mantiene pendiente para el siguiente ciclo.
      }
    }
  }

  Future<void> _depurarTelemetriaHistorica() async {
    final fechaLimite = DateTime.now()
        .subtract(Duration(days: _diasRetencionTelemetria))
        .millisecondsSinceEpoch;
    await _telemetriaDao.eliminarSincronizadosAnterioresA(fechaLimite);
  }

  Duration _obtenerEsperaPorReintento(int reintentos) {
    if (reintentos <= 0) {
      return Duration.zero;
    }
    if (reintentos == 1) {
      return const Duration(seconds: 30);
    }
    if (reintentos == 2) {
      return const Duration(minutes: 2);
    }
    return const Duration(minutes: 5);
  }

  Future<void> _manejarExcesoReintentos(String idIntento) async {
    await _telemetriaServicio.registrarEvento(
      idIntento: idIntento,
      tipo: TipoEventoTelemetria.RECONCILIACION_FALLIDA,
      descripcion: 'FINALIZADO_PROVISIONAL',
      metadatos: <String, dynamic>{'motivo': 'Maximo de reintentos superado'},
    );
    _socketServicio.emitirAlertaFraude(
      TipoEventoTelemetria.RECONCILIACION_FALLIDA,
      idIntento: idIntento,
    );
  }
}
