/// @archivo   TelemetriaDao.dart
/// @descripcion Gestiona eventos de telemetria locales para sincronizacion posterior.
/// @modulo    BaseDatosLocal/Daos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:drift/drift.dart';

import '../BaseDatosLocal.dart';

class TelemetriaDao {
  final BaseDatosLocal baseDatosLocal;

  TelemetriaDao(this.baseDatosLocal);

  /// Guarda o reemplaza un evento de telemetria local.
  Future<void> guardarEvento({
    required String id,
    required String idIntento,
    required String tipo,
    required String? metadatos,
    required int? numeroPregunta,
    required int? tiempoTranscurrido,
    required int fechaEvento,
    required bool esSincronizada,
  }) async {
    await baseDatosLocal
        .into(baseDatosLocal.telemetriaLocalTabla)
        .insertOnConflictUpdate(
          TelemetriaLocalTablaCompanion.insert(
            id: id,
            idIntento: idIntento,
            tipo: tipo,
            metadatos: Value<String?>(metadatos),
            numeroPregunta: Value<int?>(numeroPregunta),
            tiempoTranscurrido: Value<int?>(tiempoTranscurrido),
            fechaEvento: fechaEvento,
            esSincronizada: Value<bool>(esSincronizada),
          ),
        );
  }

  /// Obtiene eventos pendientes de sincronizacion.
  Future<List<TelemetriaLocalTablaData>> listarPendientes({String? idIntento}) {
    final consulta = baseDatosLocal.select(baseDatosLocal.telemetriaLocalTabla)
      ..where((tabla) => tabla.esSincronizada.equals(false));

    if (idIntento != null && idIntento.isNotEmpty) {
      consulta.where((tabla) => tabla.idIntento.equals(idIntento));
    }

    return consulta.get();
  }

  /// Marca un lote de eventos como sincronizados.
  Future<void> marcarSincronizados(List<String> idsEvento) async {
    if (idsEvento.isEmpty) {
      return;
    }

    await (baseDatosLocal.update(baseDatosLocal.telemetriaLocalTabla)
          ..where((tabla) => tabla.id.isIn(idsEvento)))
        .write(
      const TelemetriaLocalTablaCompanion(
        esSincronizada: Value<bool>(true),
      ),
    );
  }

  /// Elimina eventos sincronizados anteriores al instante indicado.
  Future<int> eliminarSincronizadosAnterioresA(int fechaLimite) {
    return (baseDatosLocal.delete(baseDatosLocal.telemetriaLocalTabla)
          ..where((tabla) =>
              tabla.esSincronizada.equals(true) &
              tabla.fechaEvento.isSmallerThanValue(fechaLimite)))
        .go();
  }
}
