/**
 * @archivo   ModalConfirmacion.tsx
 * @descripcion Presenta un diálogo de confirmación reutilizable para acciones sensibles.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Boton } from '@/Componentes/Ui/Boton';
import {
  Dialogo,
  DialogoContenido,
  DialogoDescripcion,
  DialogoEncabezado,
  DialogoTitulo,
} from '@/Componentes/Ui/Dialogo';

interface PropiedadesModalConfirmacion {
  abierto: boolean;
  titulo: string;
  descripcion: string;
  textoConfirmar?: string;
  textoCancelar?: string;
  cargando?: boolean;
  onCambiarAbierto: (abierto: boolean) => void;
  onConfirmar: () => void;
}

/**
 * Renderiza un modal con botones de confirmar/cancelar.
 */
export function ModalConfirmacion({
  abierto,
  titulo,
  descripcion,
  textoConfirmar = 'Confirmar',
  textoCancelar = 'Cancelar',
  cargando = false,
  onCambiarAbierto,
  onConfirmar,
}: PropiedadesModalConfirmacion) {
  return (
    <Dialogo open={abierto} onOpenChange={onCambiarAbierto}>
      <DialogoContenido>
        <DialogoEncabezado>
          <DialogoTitulo>{titulo}</DialogoTitulo>
          <DialogoDescripcion>{descripcion}</DialogoDescripcion>
        </DialogoEncabezado>
        <div className="flex justify-end gap-2">
          <Boton variante="contorno" onClick={() => onCambiarAbierto(false)}>
            {textoCancelar}
          </Boton>
          <Boton variante="peligro" onClick={onConfirmar} disabled={cargando}>
            {cargando ? 'Procesando...' : textoConfirmar}
          </Boton>
        </div>
      </DialogoContenido>
    </Dialogo>
  );
}
