/**
 * @archivo   EstadoIntento.ts
 * @descripcion Modela el estado de entrega y sincronización de un intento estudiantil.
 * @modulo    Enums
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export enum EstadoIntento {
  INICIADO = 'INICIADO',
  BLOQUEADO = 'BLOQUEADO',
  REANUDADO = 'REANUDADO',
  SUSPENDIDO = 'SUSPENDIDO',
  FINALIZADO_PROVISIONAL = 'FINALIZADO_PROVISIONAL',
  ENVIADO = 'ENVIADO',
  ANULADO = 'ANULADO',
}
