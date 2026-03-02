/**
 * @archivo   page.tsx
 * @descripcion Crea una nueva sesión asociándola a un examen publicado existente.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { EstadoExamen } from '@/Tipos';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useExamenes } from '@/Hooks/useExamenes';
import { useSesiones } from '@/Hooks/useSesiones';
import { CrearSesionFormulario, esquemaCrearSesion } from '@/Lib/validaciones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { AreaTexto } from '@/Componentes/Ui/AreaTexto';
import { Boton } from '@/Componentes/Ui/Boton';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeGestionarSesiones } from '@/Lib/Permisos';

/**
 * Renderiza formulario de creación de sesiones.
 */
export default function PaginaNuevaSesion() {
  const router = useRouter();
  const { usuario } = useAutenticacion();
  const { consultaExamenes } = useExamenes();
  const { mutacionCrearSesion } = useSesiones();

  const formulario = useForm<CrearSesionFormulario>({
    resolver: zodResolver(esquemaCrearSesion),
    defaultValues: { idExamen: '', descripcion: '' },
  });

  const enviar = async (datos: CrearSesionFormulario) => {
    try {
      const sesion = await mutacionCrearSesion.mutateAsync(datos);
      toast.success('Sesión creada correctamente.');
      router.push(RUTAS.SESION_DETALLE(sesion.id));
    } catch (error) {
      toast.error(obtenerMensajeError(error, 'No se pudo crear la sesión.'));
    }
  };

  if (!rolPuedeGestionarSesiones(usuario?.rol)) {
    return (
      <EstadoVacio
        titulo="Acción no permitida"
        descripcion="Solo un docente puede crear sesiones."
        etiquetaAccion="Volver a sesiones"
        hrefAccion={RUTAS.SESIONES}
      />
    );
  }

  if (consultaExamenes.isLoading) {
    return <Cargando mensaje="Cargando exámenes publicados..." />;
  }

  if (consultaExamenes.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar exámenes"
        descripcion={obtenerMensajeError(consultaExamenes.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  const examenesPublicados = (consultaExamenes.data ?? []).filter(
    (examen) => examen.estado === EstadoExamen.PUBLICADO,
  );

  return (
    <section className="space-y-4">
      <EncabezadoPagina
        etiqueta="Programación"
        titulo="Nueva sesión"
        descripcion="Selecciona un examen publicado y crea una sesión lista para activación."
      />
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Configuración de sesión</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <form className="space-y-4" onSubmit={formulario.handleSubmit(enviar)}>
          <div className="space-y-2">
            <Etiqueta>Examen</Etiqueta>
            <Seleccion value={formulario.watch('idExamen')} onValueChange={(valor) => formulario.setValue('idExamen', valor)}>
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona un examen" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {examenesPublicados.map((examen) => (
                  <SeleccionItem key={examen.id} value={examen.id}>
                    {examen.titulo}
                  </SeleccionItem>
                ))}
              </SeleccionContenido>
            </Seleccion>
            {formulario.formState.errors.idExamen ? (
              <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.idExamen.message}</p>
            ) : null}
            {examenesPublicados.length === 0 ? (
              <p className="text-sm text-[var(--estado-advertencia)]">
                Debes tener al menos un examen publicado para crear una sesión.
              </p>
            ) : null}
          </div>

          <div className="space-y-2">
            <Etiqueta htmlFor="descripcion">Descripción</Etiqueta>
            <AreaTexto id="descripcion" {...formulario.register('descripcion')} />
            {formulario.formState.errors.descripcion ? (
              <p className="text-sm text-[var(--estado-peligro)]">
                {formulario.formState.errors.descripcion.message}
              </p>
            ) : null}
          </div>

          <Boton
            type="submit"
            disabled={
              formulario.formState.isSubmitting ||
              mutacionCrearSesion.isPending ||
              examenesPublicados.length === 0
            }
          >
            {formulario.formState.isSubmitting || mutacionCrearSesion.isPending ? 'Creando...' : 'Crear sesión'}
          </Boton>
          </form>
        </TarjetaContenido>
      </Tarjeta>
    </section>
  );
}
