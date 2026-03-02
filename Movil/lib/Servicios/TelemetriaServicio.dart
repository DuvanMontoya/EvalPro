/// @archivo   TelemetriaServicio.dart
/// @descripcion Registra y sincroniza eventos de telemetria para deteccion de fraude.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import '../BaseDatosLocal/Daos/TelemetriaDao.dart';
import '../Constantes/ApiEndpoints.dart';
import '../Modelos/Enums/TipoEventoTelemetria.dart';
import 'ApiServicio.dart';

class TelemetriaServicio {
  final ApiServicio _apiServicio;
  final TelemetriaDao _telemetriaDao;

  TelemetriaServicio({
    required ApiServicio apiServicio,
    required TelemetriaDao telemetriaDao,
  })  : _apiServicio = apiServicio,
        _telemetriaDao = telemetriaDao;

  /// Registra evento de telemetria con fallback local cuando falla la red.
  Future<void> registrarEvento({
    required String idIntento,
    required TipoEventoTelemetria tipo,
    String? descripcion,
    Map<String, dynamic>? metadatos,
    int? numeroPregunta,
    int? tiempoTranscurrido,
  }) async {
    final idEvento = _generarIdEvento(idIntento, tipo);
    final fechaEvento = DateTime.now();

    try {
      await _apiServicio.publicar<void>(
        ApiEndpoints.telemetria,
        (_) => null,
        cuerpo: <String, dynamic>{
          'idIntento': idIntento,
          'tipo': tipo.name,
          'descripcion': descripcion,
          'metadatos': metadatos,
          'numeroPregunta': numeroPregunta,
          'tiempoTranscurrido': tiempoTranscurrido,
        },
      );
    } catch (_) {
      await _telemetriaDao.guardarEvento(
        id: idEvento,
        idIntento: idIntento,
        tipo: tipo.name,
        metadatos: metadatos == null ? null : jsonEncode(metadatos),
        numeroPregunta: numeroPregunta,
        tiempoTranscurrido: tiempoTranscurrido,
        fechaEvento: fechaEvento.millisecondsSinceEpoch,
        esSincronizada: false,
      );
    }
  }

  /// Registra evento y espera confirmacion inmediata de red.
  Future<void> registrarEventoSync({
    required String idIntento,
    required TipoEventoTelemetria tipo,
    String? descripcion,
    Map<String, dynamic>? metadatos,
    int? numeroPregunta,
    int? tiempoTranscurrido,
  }) {
    return registrarEvento(
      idIntento: idIntento,
      tipo: tipo,
      descripcion: descripcion,
      metadatos: metadatos,
      numeroPregunta: numeroPregunta,
      tiempoTranscurrido: tiempoTranscurrido,
    );
  }

  /// Registra un error tecnico como evento de sesion invalida.
  Future<void> registrarError(String codigo, String? detalle,
      {String? idIntento}) {
    if (idIntento == null || idIntento.isEmpty) {
      return Future<void>.value();
    }

    return registrarEvento(
      idIntento: idIntento,
      tipo: TipoEventoTelemetria.SESION_INVALIDA,
      descripcion: codigo,
      metadatos: <String, dynamic>{'detalle': detalle},
    );
  }

  String _generarIdEvento(String idIntento, TipoEventoTelemetria tipo) {
    final marca = DateTime.now().millisecondsSinceEpoch;
    return '${idIntento}_${tipo.name}_$marca';
  }
}
