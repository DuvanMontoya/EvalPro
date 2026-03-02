/**
 * @archivo   page.tsx
 * @descripcion Permite modificar metadatos de un examen existente en estado editable.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useParams, useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { useExamenDetalle, useExamenes } from '@/Hooks/useExamenes';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { CrearExamenFormulario } from '@/Lib/validaciones';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { FormularioExamen } from '@/Componentes/Examenes/FormularioExamen';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { puedeEditarContenidoExamen } from '@/Lib/Permisos';

/**
 * Renderiza formulario de edición de examen.
 */
export default function PaginaEditarExamen() {
  const parametros = useParams<{ idExamen: string }>();
  const idExamen = parametros.idExamen;
  const router = useRouter();
  const { consultaExamen } = useExamenDetalle(idExamen);
  const { mutacionActualizarExamen } = useExamenes();
  const { usuario } = useAutenticacion();

  if (consultaExamen.isLoading) {
    return <Cargando mensaje="Cargando examen..." />;
  }

  if (consultaExamen.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar el examen"
        descripcion={obtenerMensajeError(consultaExamen.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  if (!consultaExamen.data) {
    return (
      <EstadoVacio
        titulo="Examen no disponible"
        descripcion="No fue posible encontrar el examen solicitado."
        etiquetaAccion="Volver a exámenes"
        hrefAccion={RUTAS.EXAMENES}
      />
    );
  }

  const examen = consultaExamen.data;
  const puedeEditar = puedeEditarContenidoExamen(usuario?.rol, examen.estado);

  const manejarActualizar = async (datos: CrearExamenFormulario) => {
    try {
      await mutacionActualizarExamen.mutateAsync({ idExamen, dto: datos });
      toast.success('Examen actualizado correctamente.');
      router.push(RUTAS.EXAMEN_DETALLE(idExamen));
    } catch (error) {
      toast.error(obtenerMensajeError(error, 'No se pudo actualizar el examen.'));
    }
  };

  if (!puedeEditar) {
    return (
      <EstadoVacio
        titulo="Edición no disponible"
        descripcion="Solo un docente puede editar exámenes en estado borrador."
        etiquetaAccion="Volver al examen"
        hrefAccion={RUTAS.EXAMEN_DETALLE(idExamen)}
      />
    );
  }

  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Editar examen</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <FormularioExamen
          onEnviar={manejarActualizar}
          valoresIniciales={{
            ...examen,
            descripcion: examen.descripcion ?? '',
            instrucciones: examen.instrucciones ?? '',
          }}
          etiquetaBoton="Guardar cambios"
        />
      </TarjetaContenido>
    </Tarjeta>
  );
}
