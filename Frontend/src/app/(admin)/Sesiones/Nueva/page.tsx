/**
 * @archivo   page.tsx
 * @descripcion Crea una sesión canónica creando primero asignación de examen.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-03
 */
'use client';

import { useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { EstadoExamen } from '@/Tipos';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useExamenes } from '@/Hooks/useExamenes';
import { useSesiones } from '@/Hooks/useSesiones';
import { useAsignaciones } from '@/Hooks/useAsignaciones';
import { useGrupos } from '@/Hooks/useGrupos';
import { CrearSesionFormulario, esquemaCrearSesion } from '@/Lib/validaciones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { AreaTexto } from '@/Componentes/Ui/AreaTexto';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Boton } from '@/Componentes/Ui/Boton';
import { CasillaVerificacion } from '@/Componentes/Ui/CasillaVerificacion';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeGestionarSesiones } from '@/Lib/Permisos';

function formatearFechaLocalInput(fecha: Date): string {
  const fechaAjustada = new Date(fecha.getTime() - fecha.getTimezoneOffset() * 60_000);
  return fechaAjustada.toISOString().slice(0, 16);
}

function sumarMinutos(fecha: Date, minutos: number): Date {
  return new Date(fecha.getTime() + minutos * 60_000);
}

/**
 * Renderiza formulario canónico de asignación + sesión.
 */
export default function PaginaNuevaSesion() {
  const router = useRouter();
  const { usuario } = useAutenticacion();
  const { consultaExamenes } = useExamenes();
  const { mutacionCrearSesion } = useSesiones();
  const { mutacionCrearAsignacion } = useAsignaciones();
  const { consultaGrupos } = useGrupos(undefined, rolPuedeGestionarSesiones(usuario?.rol));

  const ahora = useMemo(() => new Date(), []);
  const inicioSugerido = useMemo(() => formatearFechaLocalInput(sumarMinutos(ahora, 5)), [ahora]);
  const finSugerido = useMemo(() => formatearFechaLocalInput(sumarMinutos(ahora, 65)), [ahora]);

  const formulario = useForm<CrearSesionFormulario>({
    resolver: zodResolver(esquemaCrearSesion),
    defaultValues: {
      idExamen: '',
      tipoAsignacion: 'GRUPO',
      idGrupo: '',
      idEstudiante: '',
      fechaInicio: inicioSugerido,
      fechaFin: finSugerido,
      intentosMaximos: 1,
      mostrarPuntajeInmediato: false,
      mostrarRespuestasCorrectas: false,
      publicarResultadosEn: '',
      descripcion: '',
    },
  });

  const tipoAsignacion = formulario.watch('tipoAsignacion');

  const enviar = async (datos: CrearSesionFormulario) => {
    try {
      const asignacion = await mutacionCrearAsignacion.mutateAsync({
        idExamen: datos.idExamen,
        idGrupo: datos.tipoAsignacion === 'GRUPO' ? datos.idGrupo || undefined : undefined,
        idEstudiante: datos.tipoAsignacion === 'ESTUDIANTE' ? datos.idEstudiante || undefined : undefined,
        fechaInicio: new Date(datos.fechaInicio).toISOString(),
        fechaFin: new Date(datos.fechaFin).toISOString(),
        intentosMaximos: datos.intentosMaximos,
        mostrarPuntajeInmediato: datos.mostrarPuntajeInmediato,
        mostrarRespuestasCorrectas: datos.mostrarRespuestasCorrectas,
        publicarResultadosEn: datos.publicarResultadosEn
          ? new Date(datos.publicarResultadosEn).toISOString()
          : undefined,
      });

      const sesion = await mutacionCrearSesion.mutateAsync({
        idAsignacion: asignacion.id,
        descripcion: datos.descripcion || undefined,
      });

      toast.success('Asignación y sesión creadas correctamente.');
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

  if (consultaExamenes.isLoading || consultaGrupos.isLoading) {
    return <Cargando mensaje="Cargando contexto de asignación..." />;
  }

  if (consultaExamenes.isError || consultaGrupos.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar datos para la sesión"
        descripcion={obtenerMensajeError(
          consultaExamenes.error ?? consultaGrupos.error,
          'Intenta nuevamente en unos segundos.',
        )}
      />
    );
  }

  const examenesPublicados = (consultaExamenes.data ?? []).filter(
    (examen) => examen.estado === EstadoExamen.PUBLICADO,
  );
  const gruposActivos = (consultaGrupos.data ?? []).filter((grupo) => grupo.estado === 'ACTIVO');
  const estudiantesDisponibles = Array.from(
    gruposActivos.reduce((acumulado, grupo) => {
      for (const miembro of grupo.estudiantes) {
        if (!acumulado.has(miembro.idEstudiante)) {
          acumulado.set(miembro.idEstudiante, {
            id: miembro.idEstudiante,
            nombre: `${miembro.estudiante.nombre} ${miembro.estudiante.apellidos}`,
            nombreGrupo: grupo.nombre,
          });
        }
      }
      return acumulado;
    }, new Map<string, { id: string; nombre: string; nombreGrupo: string }>()),
  ).map(([, estudiante]) => estudiante);

  if (examenesPublicados.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay exámenes publicados"
        descripcion="Debes publicar un examen antes de crear una sesión."
        etiquetaAccion="Ir a exámenes"
        hrefAccion={RUTAS.EXAMENES}
      />
    );
  }

  if (gruposActivos.length === 0) {
    return (
      <EstadoVacio
        titulo="No tienes grupos activos"
        descripcion="Asigna grupos activos a tu cuenta para crear sesiones con asignación canónica."
        etiquetaAccion="Ir a grupos"
        hrefAccion={RUTAS.GRUPOS}
      />
    );
  }

  return (
    <section className="space-y-4">
      <EncabezadoPagina
        etiqueta="Programación"
        titulo="Nueva sesión canónica"
        descripcion="Crea la asignación (grupo o estudiante) y luego genera la sesión vinculada."
      />
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Configuración de asignación y sesión</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <form className="space-y-4" onSubmit={formulario.handleSubmit(enviar)}>
            <div className="space-y-2">
              <Etiqueta>Examen publicado</Etiqueta>
              <Seleccion
                value={formulario.watch('idExamen')}
                onValueChange={(valor) => formulario.setValue('idExamen', valor)}
              >
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
            </div>

            <div className="space-y-2">
              <Etiqueta>Tipo de asignación</Etiqueta>
              <Seleccion
                value={tipoAsignacion}
                onValueChange={(valor) => formulario.setValue('tipoAsignacion', valor as 'GRUPO' | 'ESTUDIANTE')}
              >
                <SeleccionDisparador>
                  <SeleccionValor />
                </SeleccionDisparador>
                <SeleccionContenido>
                  <SeleccionItem value="GRUPO">Por grupo</SeleccionItem>
                  <SeleccionItem value="ESTUDIANTE">Individual</SeleccionItem>
                </SeleccionContenido>
              </Seleccion>
            </div>

            {tipoAsignacion === 'GRUPO' ? (
              <div className="space-y-2">
                <Etiqueta>Grupo objetivo</Etiqueta>
                <Seleccion
                  value={formulario.watch('idGrupo') || ''}
                  onValueChange={(valor) => formulario.setValue('idGrupo', valor)}
                >
                  <SeleccionDisparador>
                    <SeleccionValor placeholder="Selecciona un grupo" />
                  </SeleccionDisparador>
                  <SeleccionContenido>
                    {gruposActivos.map((grupo) => (
                      <SeleccionItem key={grupo.id} value={grupo.id}>
                        {grupo.nombre}
                      </SeleccionItem>
                    ))}
                  </SeleccionContenido>
                </Seleccion>
                {formulario.formState.errors.idGrupo ? (
                  <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.idGrupo.message}</p>
                ) : null}
              </div>
            ) : (
              <div className="space-y-2">
                <Etiqueta>Estudiante objetivo</Etiqueta>
                <Seleccion
                  value={formulario.watch('idEstudiante') || ''}
                  onValueChange={(valor) => formulario.setValue('idEstudiante', valor)}
                  disabled={estudiantesDisponibles.length === 0}
                >
                  <SeleccionDisparador>
                    <SeleccionValor placeholder="Selecciona un estudiante" />
                  </SeleccionDisparador>
                  <SeleccionContenido>
                    {estudiantesDisponibles.map((estudiante) => (
                      <SeleccionItem key={estudiante.id} value={estudiante.id}>
                        {estudiante.nombre} - {estudiante.nombreGrupo}
                      </SeleccionItem>
                    ))}
                  </SeleccionContenido>
                </Seleccion>
                {estudiantesDisponibles.length === 0 ? (
                  <p className="text-sm text-[var(--estado-advertencia)]">
                    No hay estudiantes en tus grupos activos para asignación individual.
                  </p>
                ) : null}
                {formulario.formState.errors.idEstudiante ? (
                  <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.idEstudiante.message}</p>
                ) : null}
              </div>
            )}

            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Etiqueta>Inicio (UTC local)</Etiqueta>
                <Entrada type="datetime-local" {...formulario.register('fechaInicio')} />
                {formulario.formState.errors.fechaInicio ? (
                  <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.fechaInicio.message}</p>
                ) : null}
              </div>
              <div className="space-y-2">
                <Etiqueta>Cierre (UTC local)</Etiqueta>
                <Entrada type="datetime-local" {...formulario.register('fechaFin')} />
                {formulario.formState.errors.fechaFin ? (
                  <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.fechaFin.message}</p>
                ) : null}
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Etiqueta>Intentos máximos (0 = ilimitado)</Etiqueta>
                <Entrada
                  type="number"
                  min={0}
                  max={20}
                  {...formulario.register('intentosMaximos', { valueAsNumber: true })}
                />
                {formulario.formState.errors.intentosMaximos ? (
                  <p className="text-sm text-[var(--estado-peligro)]">
                    {formulario.formState.errors.intentosMaximos.message}
                  </p>
                ) : null}
              </div>
              <div className="space-y-2">
                <Etiqueta>Publicar resultados en (opcional)</Etiqueta>
                <Entrada type="datetime-local" {...formulario.register('publicarResultadosEn')} />
                {formulario.formState.errors.publicarResultadosEn ? (
                  <p className="text-sm text-[var(--estado-peligro)]">
                    {formulario.formState.errors.publicarResultadosEn.message}
                  </p>
                ) : null}
              </div>
            </div>

            <label className="flex items-center gap-2 text-sm">
              <CasillaVerificacion
                checked={formulario.watch('mostrarPuntajeInmediato')}
                onCheckedChange={(valor) => formulario.setValue('mostrarPuntajeInmediato', Boolean(valor))}
              />
              Mostrar puntaje inmediato al enviar
            </label>

            <label className="flex items-center gap-2 text-sm">
              <CasillaVerificacion
                checked={formulario.watch('mostrarRespuestasCorrectas')}
                onCheckedChange={(valor) => formulario.setValue('mostrarRespuestasCorrectas', Boolean(valor))}
              />
              Mostrar respuestas correctas después del cierre
            </label>

            <div className="space-y-2">
              <Etiqueta htmlFor="descripcion">Descripción de sesión (opcional)</Etiqueta>
              <AreaTexto id="descripcion" {...formulario.register('descripcion')} />
              {formulario.formState.errors.descripcion ? (
                <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.descripcion.message}</p>
              ) : null}
            </div>

            <Boton
              type="submit"
              disabled={
                formulario.formState.isSubmitting ||
                mutacionCrearAsignacion.isPending ||
                mutacionCrearSesion.isPending ||
                (tipoAsignacion === 'ESTUDIANTE' && estudiantesDisponibles.length === 0)
              }
            >
              {formulario.formState.isSubmitting || mutacionCrearAsignacion.isPending || mutacionCrearSesion.isPending
                ? 'Creando...'
                : 'Crear asignación y sesión'}
            </Boton>
          </form>
        </TarjetaContenido>
      </Tarjeta>
    </section>
  );
}
