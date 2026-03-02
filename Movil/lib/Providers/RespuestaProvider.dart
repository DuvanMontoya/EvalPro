/// @archivo   RespuestaProvider.dart
/// @descripcion Administra sincronizacion manual de respuestas pendientes por intento.
/// @modulo    Providers
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Modelos/RespuestaLocal.dart';
import 'AutenticacionProvider.dart';

part 'RespuestaProvider.g.dart';

class EstadoSincronizacionRespuestas {
  final bool sincronizando;
  final int pendientes;
  final String? error;

  const EstadoSincronizacionRespuestas({
    required this.sincronizando,
    required this.pendientes,
    required this.error,
  });

  const EstadoSincronizacionRespuestas.inicial()
      : sincronizando = false,
        pendientes = 0,
        error = null;

  EstadoSincronizacionRespuestas copyWith({
    bool? sincronizando,
    int? pendientes,
    String? error,
  }) {
    return EstadoSincronizacionRespuestas(
      sincronizando: sincronizando ?? this.sincronizando,
      pendientes: pendientes ?? this.pendientes,
      error: error,
    );
  }
}

@riverpod
class RespuestaActual extends _$RespuestaActual {
  @override
  EstadoSincronizacionRespuestas build() =>
      const EstadoSincronizacionRespuestas.inicial();

  /// Sincroniza respuestas pendientes para el intento indicado.
  Future<void> sincronizarPendientes(String idIntento) async {
    state = state.copyWith(sincronizando: true, error: null);

    try {
      final pendientesTabla = await ref
          .read(respuestaDaoProvider)
          .listarPendientes(idIntento: idIntento);
      if (pendientesTabla.isEmpty) {
        state =
            state.copyWith(sincronizando: false, pendientes: 0, error: null);
        return;
      }

      final pendientes = pendientesTabla.map((fila) {
        return RespuestaLocal(
          id: fila.id,
          idIntento: fila.idIntento,
          idPregunta: fila.idPregunta,
          valorTexto: fila.valorTexto,
          opcionesSeleccionadas:
              (jsonDecode(fila.opcionesSeleccionadas ?? '[]') as List<dynamic>)
                  .map((dato) => dato as String)
                  .toList(),
          tiempoRespuesta: fila.tiempoRespuesta,
          fechaRespuesta:
              DateTime.fromMillisecondsSinceEpoch(fila.fechaRespuesta),
          esSincronizada: fila.esSincronizada,
          reintentosSincronizacion: fila.reintentosSincronizacion,
        );
      }).toList();

      await ref
          .read(respuestaServicioProvider)
          .sincronizarLote(idIntento, pendientes);
      await ref
          .read(respuestaDaoProvider)
          .marcarSincronizadas(pendientes.map((dato) => dato.id).toList());
      state = state.copyWith(sincronizando: false, pendientes: 0, error: null);
    } catch (error) {
      final cantidad = await ref
          .read(respuestaDaoProvider)
          .listarPendientes(idIntento: idIntento);
      state = state.copyWith(
        sincronizando: false,
        pendientes: cantidad.length,
        error: '$error',
      );
    }
  }
}
