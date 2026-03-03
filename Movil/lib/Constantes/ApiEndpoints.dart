/// @archivo   ApiEndpoints.dart
/// @descripcion Define segmentos de rutas HTTP consumidos por los servicios moviles.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

/// Endpoints del backend agrupados por dominio.
abstract class ApiEndpoints {
  static const autenticacionIniciarSesion = '/autenticacion/iniciar-sesion';
  static const autenticacionRefrescar = '/autenticacion/refrescar-tokens';
  static const autenticacionCerrarSesion = '/autenticacion/cerrar-sesion';

  static const sesiones = '/sesiones';
  static const sesionesBuscar = '/sesiones/buscar';
  static const examenes = '/examenes';
  static const reportes = '/reportes';
  static const instituciones = '/instituciones';
  static const usuarios = '/usuarios';
  static const grupos = '/grupos';
  static const periodos = '/periodos';
  static const reclamos = '/reclamos';
  static const respuestas = '/respuestas';

  static const intentos = '/intentos';
  static const respuestasSincronizar = '/respuestas/sincronizar-lote';
  static const respuestasPendientesCalificacion =
      '/respuestas/pendientes-calificacion';
  static const telemetria = '/telemetria';

  /// Construye endpoint para obtener examen de un intento.
  static String examenPorIntento(String idIntento) =>
      '/intentos/$idIntento/examen';

  /// Construye endpoint para finalizar intento.
  static String finalizarIntento(String idIntento) =>
      '/intentos/$idIntento/finalizar';

  /// Construye endpoint para activar una sesion.
  static String activarSesion(String idSesion) => '/sesiones/$idSesion/activar';

  /// Construye endpoint para finalizar una sesion.
  static String finalizarSesion(String idSesion) =>
      '/sesiones/$idSesion/finalizar';

  /// Construye endpoint para cancelar una sesion.
  static String cancelarSesion(String idSesion) =>
      '/sesiones/$idSesion/cancelar';

  /// Construye endpoint para publicar un examen.
  static String publicarExamen(String idExamen) =>
      '/examenes/$idExamen/publicar';

  /// Construye endpoint para archivar un examen.
  static String archivarExamen(String idExamen) => '/examenes/$idExamen';

  /// Construye endpoint para reporte por sesion.
  static String reporteSesion(String idSesion) => '/reportes/sesion/$idSesion';

  /// Construye endpoint para reporte de intentos por estudiante.
  static String reporteEstudiante(String idEstudiante) =>
      '/reportes/estudiante/$idEstudiante';

  /// Construye endpoint para crear reclamo desde un resultado.
  static String crearReclamo(String idResultado) =>
      '/resultados/$idResultado/reclamos';

  /// Construye endpoint para resolver reclamo.
  static String resolverReclamo(String idReclamo) =>
      '/reclamos/$idReclamo/resolver';

  /// Construye endpoint para cambio de estado institucional.
  static String estadoInstitucion(String idInstitucion) =>
      '/instituciones/$idInstitucion/estado';

  /// Construye endpoint para actualizar un usuario.
  static String usuarioPorId(String idUsuario) => '/usuarios/$idUsuario';

  /// Construye endpoint para asignar docente a grupo.
  static String asignarDocenteGrupo(String idGrupo) =>
      '/grupos/$idGrupo/docentes';

  /// Construye endpoint para inscribir estudiante en grupo.
  static String inscribirEstudianteGrupo(String idGrupo) =>
      '/grupos/$idGrupo/estudiantes';

  /// Construye endpoint para cambio de estado de grupo.
  static String estadoGrupo(String idGrupo) => '/grupos/$idGrupo/estado';

  /// Construye endpoint para cambio de estado de periodo.
  static String estadoPeriodo(String idPeriodo) =>
      '/periodos/$idPeriodo/estado';

  /// Construye endpoint para calificar manualmente una respuesta.
  static String calificarRespuestaManual(String idRespuesta) =>
      '/respuestas/$idRespuesta/calificar-manual';
}
