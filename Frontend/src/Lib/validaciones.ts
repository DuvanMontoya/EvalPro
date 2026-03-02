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

const PATRON_CONTRASENA_SEGURA = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$/;

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

export const esquemaCambiarContrasenaPrimerLogin = z
  .object({
    nuevaContrasena: z
      .string()
      .regex(
        PATRON_CONTRASENA_SEGURA,
        'Debe incluir mayúscula, minúscula, número y carácter especial.',
      ),
    confirmarContrasena: z.string().min(8, 'Confirma la nueva contraseña.'),
  })
  .refine((valores) => valores.nuevaContrasena === valores.confirmarContrasena, {
    message: 'Las contraseñas no coinciden.',
    path: ['confirmarContrasena'],
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

export const esquemaCrearUsuarioAcademico = z.object({
  nombre: z.string().min(2, 'El nombre debe tener al menos 2 caracteres').max(100),
  apellidos: z.string().min(2, 'Los apellidos deben tener al menos 2 caracteres').max(100),
  correo: z.string().email('Ingresa un correo válido'),
  contrasena: z.string().min(8, 'La contraseña debe tener al menos 8 caracteres'),
  rol: z.union([z.literal(RolUsuario.ESTUDIANTE), z.literal(RolUsuario.DOCENTE)]),
});

export const esquemaCrearInstitucion = z.object({
  nombre: z.string().min(3, 'El nombre debe tener al menos 3 caracteres').max(150),
  dominio: z
    .string()
    .optional()
    .or(z.literal(''))
    .refine((valor) => !valor || /^[a-z0-9.-]+\.[a-z]{2,}$/i.test(valor), {
      message: 'Ingresa un dominio válido.',
    }),
});

export const esquemaCrearPeriodoAcademico = z.object({
  nombre: z.string().min(2, 'El nombre del periodo es obligatorio').max(120),
  fechaInicio: z.string().min(1, 'Selecciona fecha de inicio'),
  fechaFin: z.string().min(1, 'Selecciona fecha de fin'),
});

export const esquemaCrearGrupo = z.object({
  nombre: z.string().min(3, 'El nombre del grupo debe tener al menos 3 caracteres').max(150),
  descripcion: z.string().max(500).optional().or(z.literal('')),
  idPeriodo: z.uuid('Selecciona un periodo académico válido'),
});

export type IniciarSesionFormulario = z.infer<typeof esquemaIniciarSesion>;
export type CambiarContrasenaPrimerLoginFormulario = z.infer<typeof esquemaCambiarContrasenaPrimerLogin>;
export type CrearExamenFormulario = z.infer<typeof esquemaCrearExamen>;
export type CrearPreguntaFormulario = z.infer<typeof esquemaCrearPregunta>;
export type CrearSesionFormulario = z.infer<typeof esquemaCrearSesion>;
export type CrearEstudianteFormulario = z.infer<typeof esquemaCrearEstudiante>;
export type CrearUsuarioAcademicoFormulario = z.infer<typeof esquemaCrearUsuarioAcademico>;
export type CrearInstitucionFormulario = z.infer<typeof esquemaCrearInstitucion>;
export type CrearPeriodoAcademicoFormulario = z.infer<typeof esquemaCrearPeriodoAcademico>;
export type CrearGrupoFormulario = z.infer<typeof esquemaCrearGrupo>;
