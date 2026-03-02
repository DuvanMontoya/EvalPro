/**
 * @archivo   JwtAutenticacion.guard.ts
 * @descripcion Protege endpoints verificando token JWT de acceso con estrategia Passport.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAutenticacionGuard extends AuthGuard('jwt-acceso') {}
