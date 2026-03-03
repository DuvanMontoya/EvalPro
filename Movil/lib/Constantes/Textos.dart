/// @archivo   Textos.dart
/// @descripcion Reune mensajes y etiquetas visibles para evitar texto magico en pantalla.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

/// Textos estandar mostrados en la aplicacion.
abstract class Textos {
  static const iniciarSesion = 'Iniciar sesion';
  static const correo = 'Correo institucional';
  static const contrasena = 'Contrasena';
  static const cerrarSesion = 'Cerrar sesion';
  static const inicio = 'Inicio';
  static const rolActual = 'Rol actual';

  static const codigoSesion = 'Codigo de sesion';
  static const buscarSesion = 'Buscar sesion';
  static const unirse = 'Unirse';
  static const gestionarSesiones = 'Gestionar sesiones';
  static const gestionarExamenes = 'Gestionar examenes';
  static const gestionarInstituciones = 'Gestionar instituciones';
  static const gestionarUsuarios = 'Gestionar usuarios';
  static const gestionarGrupos = 'Gestionar grupos';
  static const gestionarPeriodos = 'Gestionar periodos';
  static const gestionarReclamos = 'Gestionar reclamos';
  static const calificacionManual = 'Calificacion manual';
  static const misResultados = 'Mis resultados';
  static const verReporte = 'Ver reporte';
  static const activarSesion = 'Activar';
  static const finalizarSesion = 'Finalizar';
  static const cancelarSesion = 'Cancelar';
  static const publicarExamen = 'Publicar';
  static const archivarExamen = 'Archivar';
  static const sinDatos = 'Sin datos disponibles';
  static const siguiente = 'Siguiente';
  static const anterior = 'Anterior';
  static const revisarEnviar = 'Revisar y enviar';
  static const enviar = 'Enviar';
  static const examenEnviado = 'Examen enviado';

  static const sesionPendiente =
      'La sesion aun no ha iniciado. Espera al docente.';
  static const sesionFinalizada =
      'La sesion ya finalizo. No es posible unirse.';
  static const sesionCancelada = 'La sesion fue cancelada por el docente.';
  static const sinConexion = 'Sin conexion — respuestas guardadas localmente';
  static const enLinea = 'En linea';

  static const errorGeneral = 'Ocurrio un error. Intenta de nuevo.';
  static const errorInicioSesion = 'No fue posible iniciar sesion.';
  static const errorConexionServidor =
      'No fue posible conectar con el servidor. Verifica API_URL en Entornos/dev.json.';
  static const errorBusquedaSesion =
      'No fue posible buscar la sesion. Intenta nuevamente.';
  static const errorEnvioExamen =
      'No fue posible enviar el examen. Se conservaron los datos locales.';
  static const errorSincronizacion =
      'No fue posible sincronizar respuestas pendientes.';
  static const errorUsuarioInactivo =
      'Tu usuario esta inactivo. Contacta al administrador.';
  static const errorSesionNoActiva =
      'La sesion no esta activa. Espera al docente o solicita un nuevo codigo.';
  static const errorIntentoDuplicado =
      'Ya existe un intento para esta sesion. Contacta al docente.';
  static const errorTokenInvalido =
      'Tu sesion expiro. Inicia sesion nuevamente.';
  static const errorValidacion = 'Los datos enviados no son validos.';
  static const errorSinPermisos = 'No tienes permisos para esta operacion.';
  static const errorSoloEstudiantes =
      'Este flujo solo esta disponible para estudiantes.';
  static const errorGestion = 'No fue posible ejecutar la accion de gestion.';
  static const errorFormularioInvalido = 'Completa los campos requeridos.';
  static const reclamoCreado = 'Reclamo presentado correctamente.';
  static const reclamoResuelto = 'Reclamo resuelto correctamente.';
  static const respuestaCalificada = 'Respuesta calificada correctamente.';
  static const errorIdSesionInvalido =
      'No se encontro el identificador de sesion.';
  static const sinSesionActiva = 'No hay sesion activa en este momento.';
  static const examenSinPuntaje =
      'El docente no habilito visualizacion de puntaje.';
}
