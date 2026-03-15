/**
 * @archivo   FormularioExamen.tsx
 * @descripcion Construye formulario validado para crear o editar exámenes en estado borrador.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ModalidadExamen } from '@/Tipos';
import { esquemaCrearExamen, CrearExamenFormulario } from '@/Lib/validaciones';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { AreaTexto } from '@/Componentes/Ui/AreaTexto';
import { Boton } from '@/Componentes/Ui/Boton';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { CasillaVerificacion } from '@/Componentes/Ui/CasillaVerificacion';

interface PropiedadesFormularioExamen {
  valoresIniciales?: Partial<CrearExamenFormulario>;
  onEnviar: (datos: CrearExamenFormulario) => Promise<void>;
  etiquetaBoton?: string;
}

/**
 * Renderiza formulario de examen con validación en cliente.
 */
export function FormularioExamen({
  valoresIniciales,
  onEnviar,
  etiquetaBoton = 'Guardar examen',
}: PropiedadesFormularioExamen) {
  const formulario = useForm<CrearExamenFormulario>({
    resolver: zodResolver(esquemaCrearExamen),
    defaultValues: {
      titulo: valoresIniciales?.titulo ?? '',
      descripcion: valoresIniciales?.descripcion ?? '',
      instrucciones: valoresIniciales?.instrucciones ?? '',
      modalidad: valoresIniciales?.modalidad ?? ModalidadExamen.CONTENIDO_COMPLETO,
      duracionMinutos: valoresIniciales?.duracionMinutos ?? 60,
      permitirNavegacion: valoresIniciales?.permitirNavegacion ?? true,
      mostrarPuntaje: valoresIniciales?.mostrarPuntaje ?? false,
    },
  });

  const { register, handleSubmit, setValue, watch, formState } = formulario;
  const { errors, isSubmitting } = formState;

  return (
    <form className="space-y-4" onSubmit={handleSubmit(onEnviar)}>
      <div className="space-y-2">
        <Etiqueta htmlFor="titulo">Título</Etiqueta>
        <Entrada id="titulo" {...register('titulo')} />
        {errors.titulo ? <p className="text-sm text-[var(--estado-peligro)]">{errors.titulo.message}</p> : null}
      </div>

      <div className="space-y-2">
        <Etiqueta htmlFor="descripcion">Descripción</Etiqueta>
        <AreaTexto id="descripcion" {...register('descripcion')} />
        {errors.descripcion ? (
          <p className="text-sm text-[var(--estado-peligro)]">{errors.descripcion.message}</p>
        ) : null}
      </div>

      <div className="space-y-2">
        <Etiqueta htmlFor="instrucciones">Instrucciones</Etiqueta>
        <AreaTexto id="instrucciones" {...register('instrucciones')} />
        {errors.instrucciones ? (
          <p className="text-sm text-[var(--estado-peligro)]">{errors.instrucciones.message}</p>
        ) : null}
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <Etiqueta>Modalidad</Etiqueta>
          <Seleccion value={watch('modalidad')} onValueChange={(valor) => setValue('modalidad', valor as ModalidadExamen)}>
            <SeleccionDisparador>
              <SeleccionValor />
            </SeleccionDisparador>
            <SeleccionContenido>
              <SeleccionItem value={ModalidadExamen.CONTENIDO_COMPLETO}>Contenido completo</SeleccionItem>
              <SeleccionItem value={ModalidadExamen.SOLO_RESPUESTAS}>Solo respuestas</SeleccionItem>
            </SeleccionContenido>
          </Seleccion>
        </div>

        <div className="space-y-2">
          <Etiqueta htmlFor="duracionMinutos">Duración (min)</Etiqueta>
          <Entrada
            id="duracionMinutos"
            type="number"
            min={5}
            max={480}
            {...register('duracionMinutos', { valueAsNumber: true })}
          />
          {errors.duracionMinutos ? (
            <p className="text-sm text-[var(--estado-peligro)]">{errors.duracionMinutos.message}</p>
          ) : null}
        </div>
      </div>

      <label className="flex items-center gap-2 text-sm">
        <CasillaVerificacion checked={watch('permitirNavegacion')} onCheckedChange={(valor) => setValue('permitirNavegacion', Boolean(valor))} />
        Permitir navegación entre preguntas
      </label>
      <label className="flex items-center gap-2 text-sm">
        <CasillaVerificacion checked={watch('mostrarPuntaje')} onCheckedChange={(valor) => setValue('mostrarPuntaje', Boolean(valor))} />
        Mostrar puntaje al estudiante
      </label>

      <Boton type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Guardando...' : etiquetaBoton}
      </Boton>
    </form>
  );
}
