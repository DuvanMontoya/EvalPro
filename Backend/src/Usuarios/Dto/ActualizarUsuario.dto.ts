/**
 * @archivo   ActualizarUsuario.dto.ts
 * @descripcion Habilita actualización parcial de datos del usuario.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { PartialType } from '@nestjs/swagger';
import { CrearUsuarioDto } from './CrearUsuario.dto';

export class ActualizarUsuarioDto extends PartialType(CrearUsuarioDto) {}
