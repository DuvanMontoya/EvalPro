/**
 * @archivo   MaquinaEstadosIntento.util.ts
 * @descripcion Centraliza reglas de transición y estados activos/terminales de los intentos.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { BadRequestException } from '@nestjs/common';
import { EstadoIntento } from '@prisma/client';

const TRANSICIONES_VALIDAS: Record<EstadoIntento, EstadoIntento[]> = {
  [EstadoIntento.INICIADO]: [
    EstadoIntento.BLOQUEADO,
    EstadoIntento.FINALIZADO_PROVISIONAL,
    EstadoIntento.ENVIADO,
    EstadoIntento.SUSPENDIDO,
    EstadoIntento.ANULADO,
  ],
  [EstadoIntento.BLOQUEADO]: [
    EstadoIntento.REANUDADO,
    EstadoIntento.SUSPENDIDO,
    EstadoIntento.ANULADO,
  ],
  [EstadoIntento.REANUDADO]: [
    EstadoIntento.BLOQUEADO,
    EstadoIntento.FINALIZADO_PROVISIONAL,
    EstadoIntento.ENVIADO,
    EstadoIntento.SUSPENDIDO,
    EstadoIntento.ANULADO,
  ],
  [EstadoIntento.SUSPENDIDO]: [],
  [EstadoIntento.FINALIZADO_PROVISIONAL]: [
    EstadoIntento.ENVIADO,
    EstadoIntento.ANULADO,
  ],
  [EstadoIntento.ENVIADO]: [EstadoIntento.ANULADO],
  [EstadoIntento.ANULADO]: [],
};

const ESTADOS_TERMINALES = new Set<EstadoIntento>([
  EstadoIntento.ENVIADO,
  EstadoIntento.SUSPENDIDO,
  EstadoIntento.ANULADO,
]);

const ESTADOS_EDITABLES = new Set<EstadoIntento>([
  EstadoIntento.INICIADO,
  EstadoIntento.REANUDADO,
]);

const ESTADOS_MONITOREABLES = new Set<EstadoIntento>([
  EstadoIntento.INICIADO,
  EstadoIntento.BLOQUEADO,
  EstadoIntento.REANUDADO,
  EstadoIntento.FINALIZADO_PROVISIONAL,
]);

/**
 * Indica si el estado es terminal.
 * @param estado - Estado a evaluar.
 */
export function esEstadoTerminal(estado: EstadoIntento): boolean {
  return ESTADOS_TERMINALES.has(estado);
}

/**
 * Indica si el intento acepta respuestas o sincronización.
 * @param estado - Estado a evaluar.
 */
export function permiteEditarIntento(estado: EstadoIntento): boolean {
  return ESTADOS_EDITABLES.has(estado);
}

/**
 * Indica si el intento debe mostrarse como presente en monitoreo.
 * @param estado - Estado a evaluar.
 */
export function esEstadoMonitoreable(estado: EstadoIntento): boolean {
  return ESTADOS_MONITOREABLES.has(estado);
}

/**
 * Retorna los estados activos que permiten iniciar o retomar una sesión.
 */
export function obtenerEstadosActivosIntento(): EstadoIntento[] {
  return [EstadoIntento.INICIADO, EstadoIntento.REANUDADO];
}

/**
 * Retorna estados que siguen vivos para monitoreo/reconciliación.
 */
export function obtenerEstadosNoTerminalesIntento(): EstadoIntento[] {
  return [
    EstadoIntento.INICIADO,
    EstadoIntento.BLOQUEADO,
    EstadoIntento.REANUDADO,
    EstadoIntento.FINALIZADO_PROVISIONAL,
  ];
}

/**
 * Valida una transición y lanza excepción si no está permitida.
 * @param estadoActual - Estado origen.
 * @param estadoDestino - Estado destino.
 */
export function validarTransicionIntento(
  estadoActual: EstadoIntento,
  estadoDestino: EstadoIntento,
): void {
  if (esEstadoTerminal(estadoActual)) {
    throw new BadRequestException('No se pueden modificar intentos en estado terminal');
  }

  if (!TRANSICIONES_VALIDAS[estadoActual]?.includes(estadoDestino)) {
    throw new BadRequestException(
      `La transición ${estadoActual} -> ${estadoDestino} no está permitida`,
    );
  }
}
