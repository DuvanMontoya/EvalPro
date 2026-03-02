/// @archivo   TelemetriaLocalTabla.dart
/// @descripcion Define la tabla local para eventos de telemetria por intento.
/// @modulo    BaseDatosLocal/Tablas
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:drift/drift.dart';

class TelemetriaLocalTabla extends Table {
  TextColumn get id => text()();
  TextColumn get idIntento => text()();
  TextColumn get tipo => text()();
  TextColumn get metadatos => text().nullable()();
  IntColumn get numeroPregunta => integer().nullable()();
  IntColumn get tiempoTranscurrido => integer().nullable()();
  IntColumn get fechaEvento => integer()();
  BoolColumn get esSincronizada =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
