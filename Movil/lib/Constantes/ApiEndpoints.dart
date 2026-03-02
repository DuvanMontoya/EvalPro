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

  static const intentos = '/intentos';
  static const respuestasSincronizar = '/respuestas/sincronizar-lote';
  static const telemetria = '/telemetria';

  /// Construye endpoint para obtener examen de un intento.
  static String examenPorIntento(String idIntento) =>
      '/intentos/$idIntento/examen';

  /// Construye endpoint para finalizar intento.
  static String finalizarIntento(String idIntento) =>
      '/intentos/$idIntento/finalizar';
}
