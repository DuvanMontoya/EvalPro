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
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useExamenes } from '@/Hooks/useExamenes';
import { CrearExamenFormulario } from '@/Lib/validaciones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { FormularioExamen } from '@/Componentes/Examenes/FormularioExamen';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeGestionarExamenes } from '@/Lib/Permisos';

/**
 * Renderiza vista de creación de examen.
 */
export default function PaginaNuevoExamen() {
  const router = useRouter();
  const { mutacionCrearExamen } = useExamenes();
  const { usuario } = useAutenticacion();

  const manejarCrear = async (datos: CrearExamenFormulario) => {
    try {
      const examen = await mutacionCrearExamen.mutateAsync(datos);
      toast.success('Examen creado correctamente.');
      router.push(RUTAS.EXAMEN_DETALLE(examen.id));
    } catch (error) {
      toast.error(obtenerMensajeError(error, 'No se pudo crear el examen.'));
    }
  };

  if (!rolPuedeGestionarExamenes(usuario?.rol)) {
    return (
      <EstadoVacio
        titulo="Acción no permitida"
        descripcion="Solo un docente puede crear exámenes."
        etiquetaAccion="Volver a exámenes"
        hrefAccion={RUTAS.EXAMENES}
      />
    );
  }

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
