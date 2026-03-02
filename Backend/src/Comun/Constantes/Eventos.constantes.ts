/**
 * @archivo   Eventos.constantes.ts
 * @descripcion Reúne nombres de eventos WebSocket compartidos entre módulos.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export const ESPACIO_NOMBRES_SESIONES = '/sesiones';
export const EVENTO_SESION_ACTIVADA = 'sesion:activada';
export const EVENTO_SESION_FINALIZADA = 'sesion:finalizada';
export const EVENTO_ESTUDIANTE_PROGRESO = 'estudiante:progreso';
export const EVENTO_ESTUDIANTE_FRAUDE = 'estudiante:fraude_detectado';
export const EVENTO_COMANDO_FINALIZAR = 'comando:finalizar_examen';

export const EVENTO_UNIRSE_SALA = 'unirse_sala_sesion';
export const EVENTO_PROGRESO_ACTUALIZADO = 'progreso_actualizado';
export const EVENTO_ALERTA_FRAUDE = 'alerta_fraude';
