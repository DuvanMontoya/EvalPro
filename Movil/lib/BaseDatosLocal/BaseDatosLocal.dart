/// @archivo   BaseDatosLocal.dart
/// @descripcion Configura Drift SQLite y expone acceso centralizado a tablas locales.
/// @modulo    BaseDatosLocal
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'Tablas/ExamenesLocalTabla.dart';
import 'Tablas/RespuestasLocalTabla.dart';
import 'Tablas/TelemetriaLocalTabla.dart';

part 'BaseDatosLocal.g.dart';

@DriftDatabase(
  tables: <Type>[
    ExamenesLocalTabla,
    RespuestasLocalTabla,
    TelemetriaLocalTabla,
  ],
)
class BaseDatosLocal extends _$BaseDatosLocal {
  BaseDatosLocal() : super(_abrirConexion());

  /// Version del esquema local.
  @override
  int get schemaVersion => 1;
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final directorio = await getApplicationDocumentsDirectory();
    final archivo = File(path.join(directorio.path, 'evalpro_movil.sqlite'));
    return NativeDatabase.createInBackground(archivo);
  });
}
