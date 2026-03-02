/// @archivo   ExamenDao.dart
/// @descripcion Encapsula operaciones CRUD de examenes cacheados localmente.
/// @modulo    BaseDatosLocal/Daos
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../BaseDatosLocal.dart';

class ExamenDao {
  final BaseDatosLocal baseDatosLocal;

  ExamenDao(this.baseDatosLocal);

  /// Guarda o actualiza el examen local asociado a un intento.
  Future<void> guardarExamen({
    required String id,
    required String contenidoJson,
    required String idSesion,
    required String idIntento,
    required int fechaDescarga,
  }) async {
    await baseDatosLocal
        .into(baseDatosLocal.examenesLocalTabla)
        .insertOnConflictUpdate(
          ExamenesLocalTablaCompanion.insert(
            id: id,
            contenidoJson: contenidoJson,
            idSesion: idSesion,
            idIntento: idIntento,
            fechaDescarga: fechaDescarga,
          ),
        );
  }

  /// Obtiene el examen cacheado para el intento indicado.
  Future<ExamenesLocalTablaData?> obtenerPorIntento(String idIntento) {
    return (baseDatosLocal.select(baseDatosLocal.examenesLocalTabla)
          ..where((tabla) => tabla.idIntento.equals(idIntento)))
        .getSingleOrNull();
  }

  /// Elimina examenes locales asociados al intento enviado.
  Future<int> eliminarPorIntento(String idIntento) {
    return (baseDatosLocal.delete(baseDatosLocal.examenesLocalTabla)
          ..where((tabla) => tabla.idIntento.equals(idIntento)))
        .go();
  }
}
