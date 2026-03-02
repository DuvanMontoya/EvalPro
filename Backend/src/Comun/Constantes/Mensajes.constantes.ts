/**
 * @archivo   Mensajes.constantes.ts
 * @descripcion Define textos y códigos de error estándar para respuestas uniformes de la API.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export const CODIGOS_ERROR = {
  CREDENCIALES_INVALIDAS: 'CREDENCIALES_INVALIDAS',
  TOKEN_EXPIRADO: 'TOKEN_EXPIRADO',
  TOKEN_INVALIDO: 'TOKEN_INVALIDO',
  SIN_PERMISOS: 'SIN_PERMISOS',
  RECURSO_NO_ENCONTRADO: 'RECURSO_NO_ENCONTRADO',
  VALIDACION_FALLIDA: 'VALIDACION_FALLIDA',
  SESION_NO_ACTIVA: 'SESION_NO_ACTIVA',
  INTENTO_DUPLICADO: 'INTENTO_DUPLICADO',
  EXAMEN_SIN_PREGUNTAS: 'EXAMEN_SIN_PREGUNTAS',
  RECURSO_NO_PROPIO: 'RECURSO_NO_PROPIO',
  ESTADO_INVALIDO: 'ESTADO_INVALIDO',
  USUARIO_INACTIVO: 'USUARIO_INACTIVO',
  USUARIO_YA_EXISTE: 'USUARIO_YA_EXISTE',
  ROL_NO_PERMITIDO: 'ROL_NO_PERMITIDO',
  FRAUDE_DETECTADO: 'FRAUDE_DETECTADO',
  ERROR_INTERNO: 'ERROR_INTERNO',
} as const;

export const MENSAJES = {
  OPERACION_EXITOSA: 'Operación completada exitosamente',
  CREDENCIALES_INVALIDAS: 'Credenciales inválidas',
  SIN_PERMISOS: 'No tiene permisos para realizar esta operación',
  RECURSO_NO_ENCONTRADO: 'Recurso no encontrado',
  EXAMEN_SIN_PREGUNTAS: 'No se puede publicar un examen sin preguntas',
} as const;
