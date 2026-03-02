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
import { CrearExamenFormulario } from '@/Lib/validaciones';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { FormularioExamen } from '@/Componentes/Examenes/FormularioExamen';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { RUTAS } from '@/Constantes/Rutas.constantes';

/**
 * Renderiza formulario de edición de examen.
 */
export default function PaginaEditarExamen() {
  const parametros = useParams<{ idExamen: string }>();
  const idExamen = parametros.idExamen;
  const router = useRouter();
  const { consultaExamen } = useExamenDetalle(idExamen);
  const { actualizarExamen } = useExamenes();

  if (consultaExamen.isLoading || !consultaExamen.data) {
    return <Cargando mensaje="Cargando examen..." />;
  }

  const examen = consultaExamen.data;

  const manejarActualizar = async (datos: CrearExamenFormulario) => {
    await actualizarExamen(idExamen, datos);
    toast.success('Examen actualizado correctamente.');
    router.push(RUTAS.EXAMEN_DETALLE(idExamen));
  };

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
