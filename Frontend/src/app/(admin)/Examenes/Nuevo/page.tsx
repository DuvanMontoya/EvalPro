/**
 * @archivo   page.tsx
 * @descripcion Permite crear un nuevo examen desde un formulario validado.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { useExamenes } from '@/Hooks/useExamenes';
import { CrearExamenFormulario } from '@/Lib/validaciones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { FormularioExamen } from '@/Componentes/Examenes/FormularioExamen';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';

/**
 * Renderiza vista de creación de examen.
 */
export default function PaginaNuevoExamen() {
  const router = useRouter();
  const { mutacionCrearExamen } = useExamenes();

  const manejarCrear = async (datos: CrearExamenFormulario) => {
    const examen = await mutacionCrearExamen.mutateAsync(datos);
    toast.success('Examen creado correctamente.');
    router.push(RUTAS.EXAMEN_DETALLE(examen.id));
  };

  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Nuevo examen</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <FormularioExamen onEnviar={manejarCrear} etiquetaBoton="Crear examen" />
      </TarjetaContenido>
    </Tarjeta>
  );
}
