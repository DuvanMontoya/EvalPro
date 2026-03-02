/**
 * @archivo   GeneradorCodigo.util.ts
 * @descripcion Genera códigos de acceso de sesión con formato de letras mayúsculas y dígitos.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
const LETRAS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const TOTAL_LETRAS = 4;
const TOTAL_DIGITOS = 4;

/**
 * Crea un código de acceso en formato LLLL-NNNN.
 * @returns Código generado listo para guardar.
 */
export function generarCodigoSesion(): string {
  const prefijo = Array.from({ length: TOTAL_LETRAS })
    .map(() => LETRAS.charAt(Math.floor(Math.random() * LETRAS.length)))
    .join('');

  const numero = Math.floor(Math.random() * 10 ** TOTAL_DIGITOS)
    .toString()
    .padStart(TOTAL_DIGITOS, '0');

  return `${prefijo}-${numero}`;
}
