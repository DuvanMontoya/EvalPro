/// @archivo   Rutas.dart
/// @descripcion Declara todas las rutas de navegacion de la app movil.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

/// Rutas nombradas de go_router.
abstract class Rutas {
  static const iniciarSesion = '/iniciar-sesion';
  static const inicio = '/inicio';
  static const unirseExamen = '/examen/unirse';
  static const examenActivo = '/examen/activo';
  static const hojaRespuestas = '/examen/hoja-respuestas';
  static const resumenExamen = '/examen/resumen';
  static const examenEnviado = '/examen/enviado';
  static const sinConexion = '/error/sin-conexion';
  static const sesionInvalidada = '/error/sesion-invalidada';
}
