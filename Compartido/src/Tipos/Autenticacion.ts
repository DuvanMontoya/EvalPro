/**
 * @archivo   Autenticacion.ts
 * @descripcion Define la estructura compartida de sesión autenticada y tokens JWT.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Usuario } from './Usuario';

export interface TokensAutenticacion {
  tokenAcceso: string;
  tokenRefresh: string;
}

export interface SesionAutenticada extends TokensAutenticacion {
  usuario: Usuario;
}
