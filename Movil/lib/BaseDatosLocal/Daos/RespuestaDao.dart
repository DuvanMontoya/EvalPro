/// @archivo   RespuestaDao.dart
/// @descripcion Administra persistencia local de respuestas y estado de sincronizacion.
/// @modulo    BaseDatosLocal/Daos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../Modelos/RespuestaLocal.dart';
import '../BaseDatosLocal.dart';

class RespuestaDao {
  final BaseDatosLocal baseDatosLocal;

  RespuestaDao(this.baseDatosLocal);

  /// Inserta o actualiza una respuesta local por id compuesto.
  Future<void> guardarRespuesta(RespuestaLocal respuesta) async {
    await baseDatosLocal
        .into(baseDatosLocal.respuestasLocalTabla)
        .insertOnConflictUpdate(
          RespuestasLocalTablaCompanion.insert(
            id: respuesta.id,
            idIntento: respuesta.idIntento,
            idPregunta: respuesta.idPregunta,
            valorTexto: Value<String?>(respuesta.valorTexto),
            opcionesSeleccionadas:
                Value<String?>(jsonEncode(respuesta.opcionesSeleccionadas)),
            tiempoRespuesta: Value<int?>(respuesta.tiempoRespuesta),
            fechaRespuesta: respuesta.fechaRespuesta.millisecondsSinceEpoch,
            esSincronizada: Value<bool>(respuesta.esSincronizada),
            reintentosSincronizacion:
                Value<int>(respuesta.reintentosSincronizacion),
          ),
        );
  }

  /// Lista respuestas pendientes de sincronizacion por intento o global.
  Future<List<RespuestasLocalTablaData>> listarPendientes({String? idIntento}) {
    final consulta = baseDatosLocal.select(baseDatosLocal.respuestasLocalTabla)
      ..where((tabla) => tabla.esSincronizada.equals(false));

    if (idIntento != null && idIntento.isNotEmpty) {
      consulta.where((tabla) => tabla.idIntento.equals(idIntento));
    }

    return consulta.get();
  }

  /// Retorna todas las respuestas de un intento.
  Future<List<RespuestasLocalTablaData>> listarPorIntento(String idIntento) {
    return (baseDatosLocal.select(baseDatosLocal.respuestasLocalTabla)
          ..where((tabla) => tabla.idIntento.equals(idIntento)))
        .get();
  }

  /// Marca un lote de respuestas como sincronizadas.
  Future<void> marcarSincronizadas(List<String> idsRespuesta) async {
    if (idsRespuesta.isEmpty) {
      return;
    }

    await (baseDatosLocal.update(baseDatosLocal.respuestasLocalTabla)
          ..where((tabla) => tabla.id.isIn(idsRespuesta)))
        .write(
      const RespuestasLocalTablaCompanion(
        esSincronizada: Value<bool>(true),
      ),
    );
  }

  /// Incrementa el contador de reintentos para una respuesta.
  Future<void> incrementarReintentos(String idRespuesta) async {
    final existente =
        await (baseDatosLocal.select(baseDatosLocal.respuestasLocalTabla)
              ..where((tabla) => tabla.id.equals(idRespuesta)))
            .getSingleOrNull();

    if (existente == null) {
      return;
    }

    await (baseDatosLocal.update(baseDatosLocal.respuestasLocalTabla)
          ..where((tabla) => tabla.id.equals(idRespuesta)))
        .write(
      RespuestasLocalTablaCompanion(
        reintentosSincronizacion:
            Value<int>(existente.reintentosSincronizacion + 1),
      ),
    );
  }
}
