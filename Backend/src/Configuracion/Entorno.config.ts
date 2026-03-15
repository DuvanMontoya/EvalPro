/**
 * @archivo   Entorno.config.ts
 * @descripcion Valida variables críticas de entorno del backend y expone utilidades de lectura segura.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
const VARIABLES_TEXTO_OBLIGATORIAS = [
  'DATABASE_URL',
  'JWT_SECRETO_ACCESO',
  'JWT_EXPIRACION_ACCESO',
  'JWT_SECRETO_REFRESH',
  'JWT_EXPIRACION_REFRESH',
  'JWT_EMISOR',
  'JWT_AUDIENCIA',
  'HOST_APP',
  'CORS_ORIGENES_PERMITIDOS',
  'ENTORNO',
] as const;

function obtenerTextoObligatorio(
  configuracion: Record<string, unknown>,
  clave: (typeof VARIABLES_TEXTO_OBLIGATORIAS)[number],
): string {
  const valor = configuracion[clave];
  if (typeof valor !== 'string' || valor.trim().length === 0) {
    throw new Error(`La variable de entorno ${clave} es obligatoria.`);
  }
  return valor.trim();
}

function obtenerEnteroObligatorio(
  configuracion: Record<string, unknown>,
  clave: string,
  minimo: number,
): number {
  const valor = Number.parseInt(String(configuracion[clave] ?? ''), 10);
  if (!Number.isFinite(valor) || valor < minimo) {
    throw new Error(`La variable de entorno ${clave} debe ser un entero mayor o igual a ${minimo}.`);
  }
  return valor;
}

export function validarEntornoBackend(configuracion: Record<string, unknown>): Record<string, unknown> {
  for (const clave of VARIABLES_TEXTO_OBLIGATORIAS) {
    obtenerTextoObligatorio(configuracion, clave);
  }

  return {
    ...configuracion,
    PUERTO_APP: obtenerEnteroObligatorio(configuracion, 'PUERTO_APP', 1),
    BCRYPT_RONDAS_HASH: obtenerEnteroObligatorio(configuracion, 'BCRYPT_RONDAS_HASH', 12),
  };
}

export function descomponerOrigenesPermitidos(valor: string): string[] {
  const origenes = valor
    .split(',')
    .map((origen) => origen.trim())
    .filter((origen) => origen.length > 0);

  if (origenes.length === 0) {
    throw new Error('CORS_ORIGENES_PERMITIDOS debe contener al menos un origen válido.');
  }

  return origenes;
}
