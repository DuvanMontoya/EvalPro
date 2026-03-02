/**
 * @archivo   page.tsx
 * @descripcion Redirige la raíz del sitio hacia la pantalla principal del tablero.
 * @modulo    App
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { redirect } from 'next/navigation';
import { RUTAS } from '@/Constantes/Rutas.constantes';

/**
 * Redirige desde / a la ruta del tablero.
 */
export default function PaginaRaiz(): never {
  redirect(RUTAS.TABLERO);
}
