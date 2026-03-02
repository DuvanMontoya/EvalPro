/**
 * @archivo   validaciones.ts
 * @descripcion Declara esquemas Zod usados por formularios del panel administrativo.
 * @modulo    Lib
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { z } from 'zod';
import {
  ModalidadExamen,
  RolUsuario,
  TipoPregunta,
} from '@/Tipos';

const esquemaOpcion = z.object({
  letra: z
    .string()
    .min(1, 'La letra es obligatoria')
    .max(1, 'La letra debe ser única'),
  contenido: z.string().min(1, 'El contenido de la opción es obligatorio'),
  esCorrecta: z.boolean(),
  orden: z.number().int().min(1),
});

export const esquemaIniciarSesion = z.object({
  correo: z.string().email('Ingresa un correo válido'),
  contrasena: z.string().min(8, 'La contraseña debe tener al menos 8 caracteres'),
});

export const esquemaCrearExamen = z.object({
  titulo: z
    .string()
    .min(3, 'El título debe tener al menos 3 caracteres')
    .max(200, 'El título no puede superar 200 caracteres'),
  descripcion: z.string().max(1000).optional().or(z.literal('')),
  instrucciones: z.string().max(2000).optional().or(z.literal('')),
  modalidad: z.nativeEnum(ModalidadExamen),
  duracionMinutos: z
    .number({ error: 'Ingresa una duración válida' })
    .min(5, 'Mínimo 5 minutos')
    .max(480, 'Máximo 8 horas'),
  permitirNavegacion: z.boolean(),
  mostrarPuntaje: z.boolean(),
});

export const esquemaCrearPregunta = z
  .object({
    tipo: z.nativeEnum(TipoPregunta),
    enunciado: z.string().min(5, 'El enunciado debe tener al menos 5 caracteres'),
    puntaje: z.number().min(0.1, 'El puntaje mínimo es 0.1'),
    tiempoSugerido: z.number().int().min(1).optional(),
    opciones: z.array(esquemaOpcion).max(5, 'Máximo 5 opciones').optional(),
  })
  .superRefine((valor, contexto) => {
    if (valor.tipo === TipoPregunta.RESPUESTA_ABIERTA) {
      return;
    }

    if (!valor.opciones || valor.opciones.length < 2) {
      contexto.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['opciones'],
        message: 'Debes agregar al menos 2 opciones.',
      });
      return;
    }

    const totalCorrectas = valor.opciones.filter((opcion) => opcion.esCorrecta).length;
    if (
      (valor.tipo === TipoPregunta.OPCION_MULTIPLE ||
        valor.tipo === TipoPregunta.VERDADERO_FALSO) &&
      totalCorrectas !== 1
    ) {
      contexto.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['opciones'],
        message: 'Debe existir exactamente una opción correcta.',
      });
    }

    if (valor.tipo === TipoPregunta.SELECCION_MULTIPLE && totalCorrectas < 1) {
      contexto.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['opciones'],
        message: 'Debe existir al menos una opción correcta.',
      });
    }
  });

export const esquemaCrearSesion = z.object({
  idExamen: z.uuid('Selecciona un examen válido'),
  descripcion: z.string().max(255).optional().or(z.literal('')),
});

export const esquemaCrearEstudiante = z.object({
  nombre: z.string().min(2, 'El nombre debe tener al menos 2 caracteres').max(100),
  apellidos: z.string().min(2, 'Los apellidos deben tener al menos 2 caracteres').max(100),
  correo: z.string().email('Ingresa un correo válido'),
  contrasena: z.string().min(8, 'La contraseña debe tener al menos 8 caracteres'),
  rol: z.literal(RolUsuario.ESTUDIANTE),
});

export type IniciarSesionFormulario = z.infer<typeof esquemaIniciarSesion>;
export type CrearExamenFormulario = z.infer<typeof esquemaCrearExamen>;
export type CrearPreguntaFormulario = z.infer<typeof esquemaCrearPregunta>;
export type CrearSesionFormulario = z.infer<typeof esquemaCrearSesion>;
export type CrearEstudianteFormulario = z.infer<typeof esquemaCrearEstudiante>;
