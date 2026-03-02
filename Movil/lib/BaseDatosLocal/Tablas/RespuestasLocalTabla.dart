/// @archivo   RespuestasLocalTabla.dart
/// @descripcion Define la persistencia local de respuestas pendientes y sincronizadas.
/// @modulo    BaseDatosLocal/Tablas
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:drift/drift.dart';

class RespuestasLocalTabla extends Table {
  TextColumn get id => text()();
  TextColumn get idIntento => text()();
  TextColumn get idPregunta => text()();
  TextColumn get valorTexto => text().nullable()();
  TextColumn get opcionesSeleccionadas => text().nullable()();
  IntColumn get tiempoRespuesta => integer().nullable()();
  IntColumn get fechaRespuesta => integer()();
  BoolColumn get esSincronizada =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reintentosSincronizacion =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
