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

  static const codigoSesion = 'Codigo de sesion';
  static const buscarSesion = 'Buscar sesion';
  static const unirse = 'Unirse';
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
  static const sinSesionActiva = 'No hay sesion activa en este momento.';
  static const examenSinPuntaje =
      'El docente no habilito visualizacion de puntaje.';
}
