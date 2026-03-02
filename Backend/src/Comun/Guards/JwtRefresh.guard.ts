/**
 * @archivo   JwtRefresh.guard.ts
 * @descripcion Protege endpoints de renovación validando refresh token con estrategia dedicada.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtRefreshGuard extends AuthGuard('jwt-refresh') {}
