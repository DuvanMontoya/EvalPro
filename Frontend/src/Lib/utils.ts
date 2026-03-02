/**
 * @archivo   utils.ts
 * @descripcion Provee utilidades de clases CSS y formateos reutilizables del panel.
 * @modulo    Lib
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Combina clases condicionales de Tailwind con resolución de conflictos.
 * @param clases - Lista de clases condicionales.
 * @returns Cadena consolidada de clases CSS.
 */
export function cn(...clases: ClassValue[]): string {
  return twMerge(clsx(clases));
}

/**
 * Formatea una fecha ISO en formato local legible para interfaz.
 * @param valor - Fecha en string, Date o null.
 * @returns Texto de fecha amigable en español.
 */
export function formatearFecha(valor: string | Date | null): string {
  if (!valor) {
    return 'Sin fecha';
  }

  const fecha = typeof valor === 'string' ? new Date(valor) : valor;
  return fecha.toLocaleString('es-CO', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
}

/**
 * Obtiene iniciales de nombre y apellido para avatares sin imagen.
 * @param nombreCompleto - Texto con nombre y apellidos.
 * @returns Iniciales en mayúscula.
 */
export function obtenerIniciales(nombreCompleto: string): string {
  return nombreCompleto
    .split(' ')
    .filter((fragmento) => fragmento.length > 0)
    .slice(0, 2)
    .map((fragmento) => fragmento[0]?.toUpperCase() ?? '')
    .join('');
}
