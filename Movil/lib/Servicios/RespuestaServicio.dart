/// @archivo   RespuestaServicio.dart
/// @descripcion Sincroniza respuestas locales y finaliza intentos en backend.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/ApiEndpoints.dart';
import '../Modelos/RespuestaLocal.dart';
import '../Modelos/ResultadoFinal.dart';
import 'ApiServicio.dart';

class RespuestaServicio {
  final ApiServicio _apiServicio;

  RespuestaServicio(this._apiServicio);

  /// Sincroniza un lote de respuestas con estrategia idempotente.
  Future<int> sincronizarLote(
      String idIntento, List<RespuestaLocal> respuestas) async {
    final resultado = await _apiServicio.publicar<Map<String, dynamic>>(
      ApiEndpoints.respuestasSincronizar,
      (valor) => valor as Map<String, dynamic>,
      cuerpo: <String, dynamic>{
        'idIntento': idIntento,
        'respuestas': respuestas.map((respuesta) {
          return <String, dynamic>{
            'idPregunta': respuesta.idPregunta,
            'valorTexto': respuesta.valorTexto,
            'opcionesSeleccionadas': respuesta.opcionesSeleccionadas,
            'tiempoRespuesta': respuesta.tiempoRespuesta,
            'esSincronizada': respuesta.esSincronizada,
          };
        }).toList(),
      },
    );

    return (resultado['sincronizadas'] as num?)?.toInt() ?? 0;
  }

  /// Finaliza un intento y retorna puntaje cuando aplica.
  Future<ResultadoFinal> finalizarIntento(String idIntento) {
    return _apiServicio.publicar<ResultadoFinal>(
      ApiEndpoints.finalizarIntento(idIntento),
      (valor) => ResultadoFinal.fromJson(valor as Map<String, dynamic>),
    );
  }
}
