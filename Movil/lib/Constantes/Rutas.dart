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
  static const resultadosEstudiante = '/examen/resultados';
  static const examenActivo = '/examen/activo';
  static const hojaRespuestas = '/examen/hoja-respuestas';
  static const resumenExamen = '/examen/resumen';
  static const examenEnviado = '/examen/enviado';
  static const gestionSesiones = '/gestion/sesiones';
  static const gestionExamenes = '/gestion/examenes';
  static const gestionInstituciones = '/gestion/instituciones';
  static const gestionUsuarios = '/gestion/usuarios';
  static const gestionGrupos = '/gestion/grupos';
  static const gestionPeriodos = '/gestion/periodos';
  static const gestionReclamos = '/gestion/reclamos';
  static const gestionCalificacionManual = '/gestion/calificacion-manual';
  static const reporteSesion = '/gestion/sesiones/:idSesion/reporte';
  static const sinConexion = '/error/sin-conexion';
  static const sesionInvalidada = '/error/sesion-invalidada';

  /// Retorna ruta dinamica para reporte de sesion.
  static String reporteSesionPorId(String idSesion) =>
      '/gestion/sesiones/$idSesion/reporte';
}
