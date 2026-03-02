/// @archivo   IntentoServicio.dart
/// @descripcion Inicia intentos de examen para estudiantes autenticados.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Configuracion/Entorno.dart';
import '../Constantes/ApiEndpoints.dart';
import '../Modelos/IntentoExamen.dart';
import 'ApiServicio.dart';

class IntentoServicio {
  final ApiServicio _apiServicio;

  IntentoServicio(this._apiServicio);

  /// Crea un intento en backend para la sesion indicada.
  Future<IntentoExamen> iniciar(String idSesion) {
    return _apiServicio.publicar<IntentoExamen>(
      ApiEndpoints.intentos,
      (valor) => IntentoExamen.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'idSesion': idSesion,
        'versionApp': Entorno.versionApp,
      },
    );
  }
}
