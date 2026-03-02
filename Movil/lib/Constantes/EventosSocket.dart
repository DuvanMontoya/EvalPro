/// @archivo   EventosSocket.dart
/// @descripcion Agrupa nombres de eventos Socket.IO usados en monitoreo de examen.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

/// Eventos de socket emitidos o escuchados por la app movil.
abstract class EventosSocket {
  static const conectar = 'connect';
  static const desconectar = 'disconnect';
  static const unirseSalaSesion = 'unirse_sala_sesion';
  static const progresoEstudiante = 'estudiante:progreso';
  static const alertaFraude = 'estudiante:fraude_detectado';
}
