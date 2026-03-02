/**
 * @archivo   RespuestaApi.ts
 * @descripcion Describe el contrato estándar de respuestas exitosas o con error de la API.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export interface RespuestaApi<T> {
  exito: boolean;
  datos: T | null;
  mensaje: string;
  codigoError?: string;
  marcaTiempo: string;
}
