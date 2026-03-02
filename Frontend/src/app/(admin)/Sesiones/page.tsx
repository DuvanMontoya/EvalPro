/**
 * @archivo   page.tsx
 * @descripcion Lista sesiones de examen y permite gestionar su ciclo de vida desde el panel.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { toast } from 'sonner';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useSesiones } from '@/Hooks/useSesiones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Boton } from '@/Componentes/Ui/Boton';
import { TablaSesiones } from '@/Componentes/Sesiones/TablaSesiones';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeGestionarSesiones } from '@/Lib/Permisos';

/**
 * Renderiza catálogo de sesiones del docente.
 */
export default function PaginaSesiones() {
  const {
    consultaSesiones,
    mutacionActivarSesion,
    mutacionFinalizarSesion,
    mutacionCancelarSesion,
  } = useSesiones();
  const { usuario } = useAutenticacion();
  const puedeGestionar = rolPuedeGestionarSesiones(usuario?.rol);

  if (consultaSesiones.isLoading) {
    return <Cargando mensaje="Cargando sesiones..." />;
  }

  if (consultaSesiones.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar sesiones"
        descripcion={obtenerMensajeError(consultaSesiones.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  const sesiones = consultaSesiones.data ?? [];
  if (sesiones.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay sesiones"
        descripcion="Crea una sesión para iniciar exámenes con tus estudiantes."
        etiquetaAccion={puedeGestionar ? 'Nueva sesión' : undefined}
        hrefAccion={puedeGestionar ? RUTAS.SESION_NUEVA : undefined}
      />
    );
  }

  return (
    <section className="space-y-4">
      <EncabezadoPagina
        etiqueta="Operación en vivo"
        titulo="Sesiones de examen"
        descripcion="Administra activación, monitoreo, finalización y cancelación de sesiones."
        acciones={puedeGestionar ? (
          <Boton comoHijo>
            <Link href={RUTAS.SESION_NUEVA}>Nueva sesión</Link>
          </Boton>
        ) : undefined}
      />
      <TablaSesiones
        sesiones={sesiones}
        rolUsuario={usuario?.rol}
        onActivar={async (idSesion) => {
          try {
            await mutacionActivarSesion.mutateAsync(idSesion);
            toast.success('Sesión activada correctamente.');
          } catch (error) {
            toast.error(obtenerMensajeError(error, 'No se pudo activar la sesión.'));
          }
        }}
        onFinalizar={async (idSesion) => {
          try {
            await mutacionFinalizarSesion.mutateAsync(idSesion);
            toast.success('Sesión finalizada correctamente.');
          } catch (error) {
            toast.error(obtenerMensajeError(error, 'No se pudo finalizar la sesión.'));
          }
        }}
        onCancelar={async (idSesion) => {
          try {
            await mutacionCancelarSesion.mutateAsync(idSesion);
            toast.success('Sesión cancelada correctamente.');
          } catch (error) {
            toast.error(obtenerMensajeError(error, 'No se pudo cancelar la sesión.'));
          }
        }}
      />
    </section>
  );
}
