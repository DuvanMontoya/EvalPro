/**
 * @archivo   MenuUsuario.tsx
 * @descripcion Despliega acciones del usuario autenticado como cierre de sesión y datos básicos.
 * @modulo    ComponentesLayout
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { LogOut } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Avatar, AvatarFallback } from '@/Componentes/Ui/Avatar';
import {
  MenuDesplegable,
  MenuDesplegableContenido,
  MenuDesplegableDisparador,
  MenuDesplegableItem,
} from '@/Componentes/Ui/MenuDesplegable';
import { obtenerIniciales } from '@/Lib/utils';

/**
 * Renderiza menú contextual del usuario con acción de salida.
 */
export function MenuUsuario() {
  const router = useRouter();
  const { usuario, cerrarSesion } = useAutenticacion();

  const nombreCompleto = usuario ? `${usuario.nombre} ${usuario.apellidos}` : 'Usuario';

  const manejarCerrarSesion = async () => {
    await cerrarSesion();
    router.push(RUTAS.INICIO_SESION);
  };

  return (
    <MenuDesplegable>
      <MenuDesplegableDisparador className="rounded-full focus:outline-none focus:ring-2 focus:ring-primario">
        <Avatar>
          <AvatarFallback>{obtenerIniciales(nombreCompleto)}</AvatarFallback>
        </Avatar>
      </MenuDesplegableDisparador>
      <MenuDesplegableContenido align="end">
        <div className="px-2 py-1.5">
          <p className="text-sm font-medium">{nombreCompleto}</p>
          <p className="text-xs text-slate-500">{usuario?.correo}</p>
        </div>
        <hr className="my-1 border-borde" />
        <MenuDesplegableItem onClick={manejarCerrarSesion} className="text-peligro">
          <LogOut className="mr-2 inline-block h-4 w-4" />
          Cerrar sesión
        </MenuDesplegableItem>
      </MenuDesplegableContenido>
    </MenuDesplegable>
  );
}
