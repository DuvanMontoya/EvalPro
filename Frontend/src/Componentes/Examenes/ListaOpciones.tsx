/**
 * @archivo   ListaOpciones.tsx
 * @descripcion Administra la colección editable de opciones para preguntas cerradas.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { FieldArrayWithId, FieldErrors, UseFormRegister, UseFormSetValue } from 'react-hook-form';
import { TipoPregunta } from '@/Tipos';
import { CrearPreguntaFormulario } from '@/Lib/validaciones';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Boton } from '@/Componentes/Ui/Boton';
import { CasillaVerificacion } from '@/Componentes/Ui/CasillaVerificacion';

interface PropiedadesListaOpciones {
  tipo: TipoPregunta;
  campos: FieldArrayWithId<CrearPreguntaFormulario, 'opciones', 'id'>[];
  valoresOpciones: CrearPreguntaFormulario['opciones'] | undefined;
  register: UseFormRegister<CrearPreguntaFormulario>;
  setValue: UseFormSetValue<CrearPreguntaFormulario>;
  onAgregar: () => void;
  onEliminar: (indice: number) => void;
  errores: FieldErrors<CrearPreguntaFormulario>;
}

/**
 * Renderiza edición de opciones y reglas de selección correcta por tipo de pregunta.
 */
export function ListaOpciones({
  tipo,
  campos,
  valoresOpciones,
  register,
  setValue,
  onAgregar,
  onEliminar,
  errores,
}: PropiedadesListaOpciones) {
  const unicaCorrecta = tipo === TipoPregunta.OPCION_MULTIPLE || tipo === TipoPregunta.VERDADERO_FALSO;
  const bloquearCantidad = tipo === TipoPregunta.VERDADERO_FALSO;
  const puedeEliminar = campos.length > 2 && !bloquearCantidad;

  const marcarCorrecta = (indiceObjetivo: number, valor: boolean) => {
    if (unicaCorrecta) {
      campos.forEach((_, indice) => {
        setValue(`opciones.${indice}.esCorrecta`, indice === indiceObjetivo, { shouldValidate: true });
      });
      return;
    }

    setValue(`opciones.${indiceObjetivo}.esCorrecta`, valor, { shouldValidate: true });
  };

  return (
    <div className="space-y-3 rounded-md border border-[var(--borde-sutil)] p-3">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-semibold">Opciones</h4>
        <Boton
          type="button"
          tamano="pequeno"
          variante="contorno"
          onClick={onAgregar}
          disabled={campos.length >= 5 || bloquearCantidad}
        >
          Agregar opción
        </Boton>
      </div>

      {campos.map((campo, indice) => (
        <div key={campo.id} className="grid gap-2 rounded-md border border-[var(--borde-sutil)] p-3 md:grid-cols-[70px_1fr_auto_auto]">
          <Entrada {...register(`opciones.${indice}.letra`)} placeholder="A" maxLength={1} readOnly={bloquearCantidad} />
          <Entrada {...register(`opciones.${indice}.contenido`)} placeholder={`Contenido opción ${indice + 1}`} />
          <label className="flex items-center gap-2 text-sm">
            <CasillaVerificacion
              checked={Boolean(valoresOpciones?.[indice]?.esCorrecta)}
              onCheckedChange={(valor) => marcarCorrecta(indice, Boolean(valor))}
            />
            Correcta
          </label>
          <Boton
            type="button"
            tamano="pequeno"
            variante="peligro"
            onClick={() => onEliminar(indice)}
            disabled={!puedeEliminar}
          >
            Eliminar
          </Boton>
        </div>
      ))}

      {errores.opciones ? (
        <p className="text-sm text-[var(--estado-peligro)]">{errores.opciones.message as string}</p>
      ) : null}
    </div>
  );
}
