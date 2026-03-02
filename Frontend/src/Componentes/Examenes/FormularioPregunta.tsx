/**
 * @archivo   FormularioPregunta.tsx
 * @descripcion Presenta formulario validado de creación de preguntas con opciones dinámicas por tipo.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect } from 'react';
import { useFieldArray, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { TipoPregunta } from '@/Tipos';
import { CrearPreguntaFormulario, esquemaCrearPregunta } from '@/Lib/validaciones';
import { CrearPreguntaDto } from '@/Servicios/Preguntas.servicio';
import { Boton } from '@/Componentes/Ui/Boton';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { AreaTexto } from '@/Componentes/Ui/AreaTexto';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { ListaOpciones } from '@/Componentes/Examenes/ListaOpciones';

interface PropiedadesFormularioPregunta {
  onGuardar: (dto: CrearPreguntaDto) => Promise<void>;
}

/**
 * Renderiza formulario de pregunta y opciones dependientes del tipo seleccionado.
 */
export function FormularioPregunta({ onGuardar }: PropiedadesFormularioPregunta) {
  const formulario = useForm<CrearPreguntaFormulario>({
    resolver: zodResolver(esquemaCrearPregunta),
    defaultValues: {
      tipo: TipoPregunta.OPCION_MULTIPLE,
      enunciado: '',
      puntaje: 1,
      opciones: [
        { letra: 'A', contenido: '', esCorrecta: true, orden: 1 },
        { letra: 'B', contenido: '', esCorrecta: false, orden: 2 },
      ],
    },
  });

  const tipo = formulario.watch('tipo');
  const opciones = useFieldArray({ control: formulario.control, name: 'opciones' });

  useEffect(() => {
    if (tipo === TipoPregunta.RESPUESTA_ABIERTA) {
      formulario.setValue('opciones', undefined);
      return;
    }

    if (tipo === TipoPregunta.VERDADERO_FALSO) {
      formulario.setValue('opciones', [
        { letra: 'A', contenido: 'Verdadero', esCorrecta: true, orden: 1 },
        { letra: 'B', contenido: 'Falso', esCorrecta: false, orden: 2 },
      ]);
    }
  }, [formulario, tipo]);

  const agregarOpcion = () => {
    const indice = opciones.fields.length;
    const letra = String.fromCharCode(65 + indice);
    opciones.append({ letra, contenido: '', esCorrecta: false, orden: indice + 1 });
  };

  const enviar = async (datos: CrearPreguntaFormulario) => {
    await onGuardar({
      enunciado: datos.enunciado,
      tipo: datos.tipo,
      puntaje: datos.puntaje,
      tiempoSugerido: datos.tiempoSugerido,
      opciones: datos.opciones,
    });
    formulario.reset();
  };

  return (
    <form className="space-y-4" onSubmit={formulario.handleSubmit(enviar)}>
      <div className="space-y-2">
        <Etiqueta>Tipo de pregunta</Etiqueta>
        <Seleccion value={tipo} onValueChange={(valor) => formulario.setValue('tipo', valor as TipoPregunta)}>
          <SeleccionDisparador>
            <SeleccionValor />
          </SeleccionDisparador>
          <SeleccionContenido>
            <SeleccionItem value={TipoPregunta.OPCION_MULTIPLE}>Opción múltiple</SeleccionItem>
            <SeleccionItem value={TipoPregunta.SELECCION_MULTIPLE}>Selección múltiple</SeleccionItem>
            <SeleccionItem value={TipoPregunta.RESPUESTA_ABIERTA}>Respuesta abierta</SeleccionItem>
            <SeleccionItem value={TipoPregunta.VERDADERO_FALSO}>Verdadero/Falso</SeleccionItem>
          </SeleccionContenido>
        </Seleccion>
      </div>

      <div className="space-y-2">
        <Etiqueta htmlFor="enunciado">Enunciado</Etiqueta>
        <AreaTexto id="enunciado" {...formulario.register('enunciado')} />
        {formulario.formState.errors.enunciado ? (
          <p className="text-sm text-[var(--estado-peligro)]">
            {formulario.formState.errors.enunciado.message}
          </p>
        ) : null}
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <Etiqueta>Puntaje</Etiqueta>
          <Entrada type="number" step="0.1" min={0.1} {...formulario.register('puntaje', { valueAsNumber: true })} />
        </div>
        <div className="space-y-2">
          <Etiqueta>Tiempo sugerido (seg)</Etiqueta>
          <Entrada type="number" min={1} {...formulario.register('tiempoSugerido', { valueAsNumber: true })} />
        </div>
      </div>

      {tipo !== TipoPregunta.RESPUESTA_ABIERTA ? (
        <ListaOpciones
          tipo={tipo}
          campos={opciones.fields}
          register={formulario.register}
          setValue={formulario.setValue}
          onAgregar={agregarOpcion}
          onEliminar={opciones.remove}
          errores={formulario.formState.errors}
        />
      ) : null}

      <Boton type="submit" disabled={formulario.formState.isSubmitting}>
        {formulario.formState.isSubmitting ? 'Guardando...' : 'Guardar pregunta'}
      </Boton>
    </form>
  );
}
