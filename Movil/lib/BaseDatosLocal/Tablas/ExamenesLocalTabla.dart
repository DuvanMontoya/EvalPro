/// @archivo   ExamenesLocalTabla.dart
/// @descripcion Define la tabla local para cachear examenes completos por intento.
/// @modulo    BaseDatosLocal/Tablas
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:drift/drift.dart';

class ExamenesLocalTabla extends Table {
  TextColumn get id => text()();
  TextColumn get contenidoJson => text()();
  TextColumn get idSesion => text()();
  TextColumn get idIntento => text()();
  IntColumn get fechaDescarga => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
